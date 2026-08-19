#!/usr/bin/env bash
set -Eeuo pipefail

psql=(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER")

for db in mashup_production_cache mashup_production_queue mashup_production_cable; do
  "${psql[@]}" --dbname "$POSTGRES_DB" <<SQL
CREATE DATABASE ${db} OWNER ${POSTGRES_USER};
SQL
done
