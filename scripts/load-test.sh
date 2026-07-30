#!/usr/bin/env bash
set -Eeuo pipefail
readonly DURATION=600 WORKERS=50 SAMPLE_INTERVAL=15
terraform_output() { terraform -chdir=terraform/main output -raw "$1"; }

URL="$(terraform_output wordpress_url)"
PROJECT_ID="$(terraform_output project_id)"
REGION="$(terraform_output region)"
GROUP="$(terraform_output instance_group_name)"
printf 'Driving %s with %s workers for %ss.\n' "${URL}" "${WORKERS}" "${DURATION}"

SECONDS=0
for ((worker = 0; worker < WORKERS; worker++)); do
    # $1 belongs to the timeout's shell.
    # shellcheck disable=SC2016
    timeout "${DURATION}" bash -c 'while :; do curl --insecure --silent --max-time 30 --output /dev/null "$1" || true; done' _ "${URL}" &
done

while ((SECONDS < DURATION)); do
    TARGET_SIZE="$(gcloud compute instance-groups managed describe "${GROUP}" --project="${PROJECT_ID}" --region="${REGION}" --format='value(targetSize)')"
    HTTP_STATUS="$(curl --insecure --silent --show-error --max-time 30 --output /dev/null --write-out '%{http_code}' "${URL}" || true)"
    printf '%s target=%s http=%s\n' "$(date -u +%FT%TZ)" "${TARGET_SIZE}" "${HTTP_STATUS}"
    sleep "${SAMPLE_INTERVAL}"
done
wait || true
