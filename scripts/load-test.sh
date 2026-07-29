#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: load-test.sh URL PROJECT_ID REGION GROUP DURATION CONCURRENCY INTERVAL SETTLE_TIMEOUT

All time values are integer seconds. The script drives concurrent requests for
DURATION, samples site availability and group size every INTERVAL, then watches
the group return to its two-instance floor for at most SETTLE_TIMEOUT.
USAGE
}

if [[ $# -ne 8 ]]; then
  usage >&2
  exit 2
fi

url=$1
project_id=$2
region=$3
group=$4
duration=$5
concurrency=$6
sample_interval=$7
settle_timeout=$8

for value in "$duration" "$concurrency" "$sample_interval" "$settle_timeout"; do
  if [[ ! $value =~ ^[1-9][0-9]*$ ]]; then
    printf 'Expected a positive integer, got: %s\n' "$value" >&2
    exit 2
  fi
done

worker_pids=()

# Called indirectly by the EXIT trap.
# shellcheck disable=SC2317
stop_workers() {
  if ((${#worker_pids[@]} > 0)); then
    kill "${worker_pids[@]}" 2>/dev/null || true
  fi
}

trap stop_workers EXIT

load_worker() {
  local worker_duration=$1
  local end_second=$((SECONDS + worker_duration))
  local failed=0

  while ((SECONDS < end_second)); do
    if ! curl --insecure --fail --silent --show-error \
      --max-time 30 --output /dev/null "$url"; then
      failed=1
    fi
  done

  return "$failed"
}

availability_failures=0
target_size=0
actual_size=0
peak_target_size=0
peak_actual_size=0

sample() {
  local phase=$1
  local status

  target_size=$(gcloud compute instance-groups managed describe "$group" \
    --project="$project_id" \
    --region="$region" \
    --format='value(targetSize)')
  actual_size=$(gcloud compute instance-groups managed list-instances "$group" \
    --project="$project_id" \
    --region="$region" \
    --format='value(instance)' | awk 'NF { count++ } END { print count + 0 }')
  status=$(curl --insecure --silent --show-error \
    --max-time 30 --output /dev/null --write-out '%{http_code}' "$url" || true)

  if [[ ! $status =~ ^[23][0-9][0-9]$ ]]; then
    availability_failures=$((availability_failures + 1))
  fi

  if ((target_size > peak_target_size)); then
    peak_target_size=$target_size
  fi
  if ((actual_size > peak_actual_size)); then
    peak_actual_size=$actual_size
  fi

  printf '%s phase=%-8s target=%s actual=%s http=%s\n' \
    "$(date -u +%FT%TZ)" "$phase" "$target_size" "$actual_size" "${status:-000}"
}

load_end=$((SECONDS + duration))
printf 'Driving %s with %s workers for %ss.\n' "$url" "$concurrency" "$duration"
printf 'The test will then wait up to %ss for the group to return to two.\n' "$settle_timeout"

for ((worker = 1; worker <= concurrency; worker++)); do
  load_worker "$duration" &
  worker_pids+=("$!")
done

while ((SECONDS < load_end)); do
  sample load
  sleep "$sample_interval"
done

worker_failures=0
for pid in "${worker_pids[@]}"; do
  if ! wait "$pid"; then
    worker_failures=$((worker_failures + 1))
  fi
done
worker_pids=()

printf 'Load stopped; watching scale-in.\n'
settle_end=$((SECONDS + settle_timeout))

while ((SECONDS < settle_end)); do
  sample scale-in
  if ((target_size == 2 && actual_size == 2)); then
    if ((peak_target_size <= 2 || peak_actual_size <= 2)); then
      printf 'The group returned to two but scale-out was not observed (peak target=%s actual=%s).\n' \
        "$peak_target_size" "$peak_actual_size" >&2
      exit 1
    fi
    if ((availability_failures > 0 || worker_failures > 0)); then
      printf 'Scale-out succeeded, but availability failed in %s sample(s) and %s worker(s).\n' \
        "$availability_failures" "$worker_failures" >&2
      exit 1
    fi

    printf 'The group scaled to %s/%s (target/actual), returned to two, and every availability sample succeeded.\n' \
      "$peak_target_size" "$peak_actual_size"
    exit 0
  fi
  sleep "$sample_interval"
done

printf 'Timed out before the group returned to two (target=%s actual=%s).\n' \
  "$target_size" "$actual_size" >&2
exit 1
