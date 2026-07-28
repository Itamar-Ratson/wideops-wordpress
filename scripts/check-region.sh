#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROJECT_FILE="${ROOT_DIR}/terraform/project.tfvars"

project_id=$(awk -F'"' '/^project_id/{print $2}' "${PROJECT_FILE}")
region=$(awk -F'"' '/^region/{print $2}' "${PROJECT_FILE}")

if [[ -z "${project_id}" || -z "${region}" ]]; then
  echo "project_id and region must both be set in ${PROJECT_FILE}" >&2
  exit 1
fi

echo "Checking GCP product availability for ${project_id} in ${region}..."

machine_types=$(gcloud compute machine-types list \
  --project="${project_id}" \
  --filter="zone~${region} AND name=e2-medium" \
  --format='value(zone.basename(),name)' \
  --quiet)

if [[ -z "${machine_types}" ]]; then
  echo "e2-medium is not available in any ${region} zone" >&2
  exit 1
fi

sql_tiers=$(gcloud sql tiers list \
  --project="${project_id}" \
  --filter='tier=db-g1-small' \
  --format='value(tier,region)' \
  --quiet)

if ! grep -q "${region}" <<<"${sql_tiers}"; then
  echo "db-g1-small is not available in ${region}" >&2
  exit 1
fi

repository_locations=$(gcloud artifacts locations list \
  --project="${project_id}" \
  --filter="name=${region}" \
  --format='value(name)' \
  --quiet)

if [[ -z "${repository_locations}" ]]; then
  echo "Artifact Registry is not available in ${region}" >&2
  exit 1
fi

printf 'e2-medium:\n%s\n' "${machine_types}"
printf 'db-g1-small: %s\n' "${region}"
printf 'Artifact Registry: %s\n' "${repository_locations}"
echo "Region check passed."
