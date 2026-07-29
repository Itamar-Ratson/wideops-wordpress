#!/usr/bin/env bash
# Creates the self-signed certificate outside Terraform so its private key can
# never be written to Terraform state. If registration previously succeeded,
# the script exits before touching the local certificate or key.
set -Eeuo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s PROJECT_ID\n' "$0" >&2
    exit 2
fi

readonly PROJECT_ID="$1"
readonly CERTIFICATE_NAME=wp-self-signed
readonly CERTIFICATE_HOSTNAME=wideops-wordpress.invalid
REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPOSITORY_ROOT
readonly CERTIFICATE_DIRECTORY="${REPOSITORY_ROOT}/.certificates"
readonly CERTIFICATE_FILE="${CERTIFICATE_DIRECTORY}/wordpress.crt"
readonly PRIVATE_KEY_FILE="${CERTIFICATE_DIRECTORY}/wordpress.key"

registered_certificate="$(
    gcloud compute ssl-certificates list \
        --global \
        --project="${PROJECT_ID}" \
        --filter="name=${CERTIFICATE_NAME}" \
        --format='value(name)'
)"

if [[ "${registered_certificate}" == "${CERTIFICATE_NAME}" ]]; then
    printf 'Certificate %s already exists; leaving it unchanged.\n' \
        "${CERTIFICATE_NAME}"
    exit 0
fi

install -d -m 0700 "${CERTIFICATE_DIRECTORY}"
umask 077

if [[ -e "${CERTIFICATE_FILE}" || -e "${PRIVATE_KEY_FILE}" ]]; then
    if [[ ! -f "${CERTIFICATE_FILE}" || ! -f "${PRIVATE_KEY_FILE}" ]]; then
        printf 'Refusing to use an incomplete local certificate pair in %s.\n' \
            "${CERTIFICATE_DIRECTORY}" >&2
        exit 1
    fi
else
    openssl req \
        -x509 \
        -newkey rsa:2048 \
        -sha256 \
        -nodes \
        -days 365 \
        -keyout "${PRIVATE_KEY_FILE}" \
        -out "${CERTIFICATE_FILE}" \
        -subj "/CN=${CERTIFICATE_HOSTNAME}" \
        -addext "subjectAltName=DNS:${CERTIFICATE_HOSTNAME}"
fi

gcloud compute ssl-certificates create "${CERTIFICATE_NAME}" \
    --project="${PROJECT_ID}" \
    --certificate="${CERTIFICATE_FILE}" \
    --private-key="${PRIVATE_KEY_FILE}" \
    --global

printf 'Registered certificate %s; private key remains only at %s.\n' \
    "${CERTIFICATE_NAME}" "${PRIVATE_KEY_FILE}"
