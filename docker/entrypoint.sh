#!/usr/bin/env bash
set -euo pipefail

rockyou_txt="/usr/share/wordlists/rockyou.txt"
rockyou_gz="${rockyou_txt}.gz"
if [[ -f "$rockyou_gz" && ! -f "$rockyou_txt" ]]; then
  gzip -dk "$rockyou_gz" || true
fi

if [[ "${1:-server}" == "server" ]]; then
  set -- python3 hexstrike_server.py --port "${HEXSTRIKE_PORT:-8888}"
fi

exec "$@"
