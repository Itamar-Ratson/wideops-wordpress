#!/usr/bin/env bash
set -Eeuo pipefail

terraform_output() { terraform -chdir=terraform/main output -raw "$1"; }

PROJECT_ID="$(terraform_output project_id)"
SQL_INSTANCE="$(terraform_output sql_instance_name)"
UPLOADS_URI="$(terraform_output uploads_uri)"
DATABASE_DUMP_URI="$(terraform_output database_dump_uri)"
URL_REWRITE_URI="$(terraform_output url_rewrite_uri)"

gcloud storage rsync --recursive app/wp-content/uploads "${UPLOADS_URI}" \
    --project="${PROJECT_ID}"
gcloud sql import sql "${SQL_INSTANCE}" "${DATABASE_DUMP_URI}" \
    --project="${PROJECT_ID}" --database=wordpress --quiet
gcloud sql import sql "${SQL_INSTANCE}" "${URL_REWRITE_URI}" \
    --project="${PROJECT_ID}" --database=wordpress --quiet

printf 'Seeded the database, uploads, and relative post URLs.\n'
