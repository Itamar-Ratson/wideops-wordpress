#!/usr/bin/env bash
# Applies the same rewrite used by the local check after the dump import. The
# generated SQL is staged in the existing private assets bucket because the
# Cloud SQL control plane is the only migration path to the private instance.
set -Eeuo pipefail

if (( $# != 4 )); then
    printf 'Usage: %s PROJECT_ID SQL_INSTANCE BUCKET_URI LOAD_BALANCER_IP\n' "$0" >&2
    exit 2
fi

readonly PROJECT_ID="$1"
readonly SQL_INSTANCE="$2"
readonly BUCKET_URI="$3"
readonly LOAD_BALANCER_IP="$4"
REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPOSITORY_ROOT
readonly REWRITE_SQL="${REPOSITORY_ROOT}/data/rewrite-urls.sql"
readonly STAGED_REWRITE_URI="${BUCKET_URI}/seed/rewrite-public-urls.sql"

if [[ ! "${LOAD_BALANCER_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    printf 'Invalid load-balancer IPv4 address: %s\n' "${LOAD_BALANCER_IP}" >&2
    exit 1
fi

IFS=. read -r -a address_octets <<< "${LOAD_BALANCER_IP}"
for octet in "${address_octets[@]}"; do
    if (( 10#${octet} > 255 )); then
        printf 'Invalid load-balancer IPv4 address: %s\n' "${LOAD_BALANCER_IP}" >&2
        exit 1
    fi
done

{
    printf "SET @destination = 'https://%s';\n" "${LOAD_BALANCER_IP}"
    cat "${REWRITE_SQL}"
} | gcloud storage cp - "${STAGED_REWRITE_URI}" --project="${PROJECT_ID}"

gcloud sql import sql "${SQL_INSTANCE}" "${STAGED_REWRITE_URI}" \
    --project="${PROJECT_ID}" \
    --database=wordpress \
    --quiet

printf 'Rewrote the supplied site URLs to https://%s.\n' "${LOAD_BALANCER_IP}"
