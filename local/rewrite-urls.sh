#!/usr/bin/env bash
# Runs inside the MySQL container during first-time initialisation, once the
# supplied dump has been imported, and applies the shared URL rewrite with the
# local site address as its destination.
#
# rewrite-urls.sql is mounted outside /docker-entrypoint-initdb.d on purpose:
# the entrypoint runs each init file in its own mysql session, so run on its own
# the rewrite would find @destination unset and abort.
set -Eeuo pipefail

readonly REWRITE_SQL=/opt/rewrite-urls.sql

{
    printf "SET @destination = '%s';\n" "${SITE_URL}"
    cat "${REWRITE_SQL}"
} | MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql --user=root "${MYSQL_DATABASE}"
