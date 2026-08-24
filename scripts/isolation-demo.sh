#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'Step 1: inspect the process view before isolation.'
ps -o pid,ppid,comm | sed -n '1,8p'
printf '%s\n' 'Step 2: create a user and PID namespace with a private process view.'
if unshare --user --map-root-user --pid --mount-proc sh -c 'printf "isolated PID  PID1=%s\\n" "$$"; ps -o pid,ppid,comm'; then
  printf '%s\n' 'Step 3: compare the isolated PID 1 with the host process list.'
else
  printf '%s\n' 'Namespace creation is unavailable in this WSL2 configuration.'
  printf '%s\n' 'Rerun on a distro with unprivileged user namespaces enabled.'
fi
