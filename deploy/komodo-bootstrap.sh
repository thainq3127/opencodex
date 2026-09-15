#!/bin/sh
set -eu

compose_file="${COMPOSE_FILE:-compose.komodo.yaml}"
token_path="/home/bun/.opencodex/service-api-token"

if docker compose -f "$compose_file" run --rm --no-deps -T hub +  sh -lc "test -s '$token_path'"; then
  echo "OpenCodex data-plane token already initialized."
  exit 0
fi

token="$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')"
trap 'token=' EXIT HUP INT TERM

printf '%s\n' "$token" | docker compose -f "$compose_file" run --rm --no-deps -T hub +  bun run docker/bootstrap-token.ts

echo "OpenCodex data-plane token initialized."
