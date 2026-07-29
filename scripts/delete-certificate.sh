#!/usr/bin/env bash
# Removes the certificate that create-certificate.sh registered. The local
# certificate and key are left in place so a later make certificate can
# register the same pair again.
set -Eeuo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s PROJECT_ID\n' "$0" >&2
    exit 2
fi

readonly PROJECT_ID="$1"
readonly CERTIFICATE_NAME=wp-self-signed

registered_certificate="$(
    gcloud compute ssl-certificates list \
        --global \
        --project="${PROJECT_ID}" \
        --filter="name=${CERTIFICATE_NAME}" \
        --format='value(name)'
)"

if [[ "${registered_certificate}" != "${CERTIFICATE_NAME}" ]]; then
    printf 'Certificate %s is not registered; nothing to delete.\n' \
        "${CERTIFICATE_NAME}"
    exit 0
fi

gcloud compute ssl-certificates delete "${CERTIFICATE_NAME}" \
    --project="${PROJECT_ID}" \
    --global \
    --quiet

printf 'Deleted certificate %s.\n' "${CERTIFICATE_NAME}"
