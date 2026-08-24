#!/usr/bin/env bash
set -euo pipefail
port="${1:-18080}"
log=$(mktemp)
trap 'kill "$server" 2>/dev/null || true; rm -f "$log"' EXIT
printf '%s\n' 'Step 1: inspect the client/server source and socket lifecycle.'
sed -n '1,240p' demos/network/echo.py
printf '%s\n' 'Step 2: start the server in the background.'
python3 demos/network/echo.py server "$port" >"$log" 2>&1 & server=$!
sleep 0.2
printf '%s\n' 'Step 3: connect a client and send one line.'
printf 'hello from the client\n' | python3 demos/network/echo.py client 127.0.0.1 "$port"
printf '%s\n' 'Step 4: inspect the server observation.'
cat "$log"
