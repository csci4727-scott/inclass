#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'Step 1: inspect the tracepoint program and its hook.'
sed -n '1,160p' demos/ebpf/exec-trace.bt
printf '%s\n' 'Step 2: run the live trace when bpftrace is available.'
if command -v bpftrace >/dev/null 2>&1; then
  printf '%s\n' 'In a second terminal, run: sudo bpftrace demos/ebpf/exec-trace.bt'
  printf '%s\n' 'Then execute a command here and compare the event with the hook.'
else
  printf '%s\n' 'bpftrace is unavailable; this WSL2 fallback still exposes the hook and verifier boundary.'
  printf '%s\n' 'Install bpftrace and rerun this target for live kernel events.'
fi
