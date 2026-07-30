#!/usr/bin/env bash
set -Eeuo pipefail

terraform_output() { terraform -chdir=terraform/main output -raw "$1"; }

PROJECT_ID="$(terraform_output project_id)"
SQL_INSTANCE="$(terraform_output sql_instance_name)"
ASSETS_URI="$(terraform_output assets_uri)"
UPLOADS_URI="$(terraform_output uploads_uri)"
DATABASE_DUMP_URI="$(terraform_output database_dump_uri)"
WORDPRESS_URL="$(terraform_output wordpress_url)"
STAGED_REWRITE_URI="${ASSETS_URI}/seed/rewrite-public-urls.sql"

gcloud storage rsync --recursive app/wp-content/uploads "${UPLOADS_URI}" \
    --project="${PROJECT_ID}"
gcloud sql import sql "${SQL_INSTANCE}" "${DATABASE_DUMP_URI}" \
    --project="${PROJECT_ID}" --database=wordpress --quiet

{
    printf "SET @destination = '%s';\n" "${WORDPRESS_URL}"
    cat data/rewrite-urls.sql
} | gcloud storage cp - "${STAGED_REWRITE_URI}" --project="${PROJECT_ID}"

gcloud sql import sql "${SQL_INSTANCE}" "${STAGED_REWRITE_URI}" \
    --project="${PROJECT_ID}" --database=wordpress --quiet

printf 'Seeded the database, uploads, and public URL for %s.\n' "${WORDPRESS_URL}"
