#!/usr/bin/env bash
# Demonstrates autoscaling and availability against the deployed site. This
# observes runtime behaviour rather than declaring it, so it lives outside
# Terraform: it drives concurrent requests through the public entry point,
# samples group size and availability throughout, then watches the group return
# to its floor once load stops.
set -Eeuo pipefail

# Must match min_replicas in terraform/main/compute.tf.
readonly FLOOR=2

readonly DEFAULT_DURATION=600
readonly DEFAULT_CONCURRENCY=50
readonly DEFAULT_SAMPLE_INTERVAL=15
# Scale-in returns the target to the floor promptly but drains the surplus
# instances over several more minutes, and the test waits for both. An observed
# run took 19m09s, so 20 minutes left too little margin to be a useful default.
readonly DEFAULT_SETTLE_TIMEOUT=1800

if (( $# != 4 )); then
    cat >&2 <<USAGE
Usage: $0 URL PROJECT_ID REGION GROUP

Tuning is read from the environment, in integer seconds except the worker count:
  LOAD_DURATION         seconds to drive load for  (default ${DEFAULT_DURATION})
  LOAD_CONCURRENCY      concurrent workers         (default ${DEFAULT_CONCURRENCY})
  LOAD_SAMPLE_INTERVAL  seconds between samples    (default ${DEFAULT_SAMPLE_INTERVAL})
  LOAD_SETTLE_TIMEOUT   seconds to await scale-in  (default ${DEFAULT_SETTLE_TIMEOUT})
USAGE
    exit 2
fi

readonly URL="$1"
readonly PROJECT_ID="$2"
readonly REGION="$3"
readonly GROUP="$4"

readonly DURATION="${LOAD_DURATION:-${DEFAULT_DURATION}}"
readonly CONCURRENCY="${LOAD_CONCURRENCY:-${DEFAULT_CONCURRENCY}}"
readonly SAMPLE_INTERVAL="${LOAD_SAMPLE_INTERVAL:-${DEFAULT_SAMPLE_INTERVAL}}"
readonly SETTLE_TIMEOUT="${LOAD_SETTLE_TIMEOUT:-${DEFAULT_SETTLE_TIMEOUT}}"

for value in "${DURATION}" "${CONCURRENCY}" "${SAMPLE_INTERVAL}" "${SETTLE_TIMEOUT}"; do
    if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
        printf 'Expected a positive integer, got: %s\n' "${value}" >&2
        exit 2
    fi
done

worker_pids=()

# Called indirectly by the EXIT trap.
# shellcheck disable=SC2317
stop_workers() {
    if (( ${#worker_pids[@]} > 0 )); then
        kill "${worker_pids[@]}" 2>/dev/null || true
    fi
}

trap stop_workers EXIT

load_worker() {
    local worker_duration="$1"
    local end_second=$(( SECONDS + worker_duration ))
    local failed=0

    while (( SECONDS < end_second )); do
        if ! curl --insecure --fail --silent --show-error \
            --max-time 30 --output /dev/null "${URL}"; then
            failed=1
        fi
    done

    return "${failed}"
}

# sample() updates these; the scale-in loop reads the first two to decide when
# the group has settled, and the exit checks read the rest.
target_size=0
actual_size=0
availability_failures=0
peak_target_size=0
peak_actual_size=0

sample() {
    local phase="$1"
    local status

    target_size=$(gcloud compute instance-groups managed describe "${GROUP}" \
        --project="${PROJECT_ID}" \
        --region="${REGION}" \
        --format='value(targetSize)')
    # awk rather than wc -l so that no instances counts as 0, not 1.
    actual_size=$(gcloud compute instance-groups managed list-instances "${GROUP}" \
        --project="${PROJECT_ID}" \
        --region="${REGION}" \
        --format='value(instance)' | awk 'NF { count++ } END { print count + 0 }')
    status=$(curl --insecure --silent --show-error \
        --max-time 30 --output /dev/null --write-out '%{http_code}' "${URL}" || true)

    if [[ ! "${status}" =~ ^[23][0-9][0-9]$ ]]; then
        availability_failures=$(( availability_failures + 1 ))
    fi

    if (( target_size > peak_target_size )); then
        peak_target_size="${target_size}"
    fi
    if (( actual_size > peak_actual_size )); then
        peak_actual_size="${actual_size}"
    fi

    printf '%s phase=%-8s target=%s actual=%s http=%s\n' \
        "$(date -u +%FT%TZ)" "${phase}" "${target_size}" "${actual_size}" "${status:-000}"
}

printf 'Driving %s with %s workers for %ss.\n' "${URL}" "${CONCURRENCY}" "${DURATION}"
printf 'The test will then wait up to %ss for the group to return to %s.\n' \
    "${SETTLE_TIMEOUT}" "${FLOOR}"

load_end=$(( SECONDS + DURATION ))

for (( worker = 1; worker <= CONCURRENCY; worker++ )); do
    load_worker "${DURATION}" &
    worker_pids+=("$!")
done

while (( SECONDS < load_end )); do
    sample load
    sleep "${SAMPLE_INTERVAL}"
done

worker_failures=0
for pid in "${worker_pids[@]}"; do
    if ! wait "${pid}"; then
        worker_failures=$(( worker_failures + 1 ))
    fi
done
worker_pids=()

printf 'Load stopped; watching scale-in.\n'
settle_end=$(( SECONDS + SETTLE_TIMEOUT ))

while (( SECONDS < settle_end )); do
    sample scale-in
    if (( target_size == FLOOR && actual_size == FLOOR )); then
        break
    fi
    sleep "${SAMPLE_INTERVAL}"
done

if (( target_size != FLOOR || actual_size != FLOOR )); then
    printf 'Timed out before the group returned to %s (target=%s actual=%s).\n' \
        "${FLOOR}" "${target_size}" "${actual_size}" >&2
    exit 1
fi

if (( peak_target_size <= FLOOR || peak_actual_size <= FLOOR )); then
    printf 'The group returned to %s but scale-out was not observed (peak target=%s actual=%s).\n' \
        "${FLOOR}" "${peak_target_size}" "${peak_actual_size}" >&2
    exit 1
fi

if (( availability_failures > 0 || worker_failures > 0 )); then
    printf 'Scale-out succeeded, but availability failed in %s sample(s) and %s worker(s).\n' \
        "${availability_failures}" "${worker_failures}" >&2
    exit 1
fi

printf 'The group scaled to %s/%s (target/actual), returned to %s, and every availability sample succeeded.\n' \
    "${peak_target_size}" "${peak_actual_size}" "${FLOOR}"
