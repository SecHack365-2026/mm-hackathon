#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_PATH="${1:-$SCRIPT_DIR/mm_data.db}"

sqlite3 "$DB_PATH" < "$SCRIPT_DIR/refresh_dummy_data.sql"

shopt -s nullglob
seed_files=("$SCRIPT_DIR"/conversation_seeds/*.sql)
if [[ ${#seed_files[@]} -eq 0 ]]; then
    echo "No conversation seed SQL files found" >&2
    exit 1
fi

for seed_file in "${seed_files[@]}"; do
    sqlite3 "$DB_PATH" < "$seed_file"
done

sqlite3 "$DB_PATH" 'PRAGMA integrity_check; PRAGMA foreign_key_check;'
