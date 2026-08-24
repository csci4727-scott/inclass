#!/usr/bin/env bash
set -euo pipefail

name=${1:?demo name required}
gdb_file=${2:?GDB command file required}

if [[ ! -d xv6/.git && ! -f xv6/Makefile ]]; then
  echo "xv6 is not initialized; run git submodule update --init --recursive" >&2
  exit 2
fi
command -v qemu-system-riscv64 >/dev/null || { echo "qemu-system-riscv64 is required" >&2; exit 2; }
if command -v riscv64-unknown-elf-gdb >/dev/null; then
  GDB=riscv64-unknown-elf-gdb
elif command -v gdb-multiarch >/dev/null; then
  GDB=gdb-multiarch
else
  echo "riscv64-unknown-elf-gdb or gdb-multiarch is required" >&2
  exit 2
fi

echo "==> Demo: $name"
echo "==> GDB commands: $gdb_file"
echo "==> Open the corresponding xv6 kernel source before continuing."
port=$(make -s -C xv6 print-gdbport)
echo "==> Running: make -C xv6 qemu-gdb (GDB port $port)"
make -C xv6 qemu-gdb &
qemu_pid=$!
cleanup() {
  kill "$qemu_pid" 2>/dev/null || true
  for child in $(pgrep -P "$qemu_pid" 2>/dev/null || true); do
    kill "$child" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM
for _ in $(seq 1 120); do
  if [[ -f xv6/kernel/kernel ]]; then
    break
  fi
  if ! kill -0 "$qemu_pid" 2>/dev/null; then
    echo "xv6 build/QEMU process exited before producing xv6/kernel/kernel" >&2
    exit 1
  fi
  sleep 0.25
done
if [[ ! -f xv6/kernel/kernel ]]; then
  echo "timed out waiting for xv6/kernel/kernel" >&2
  exit 1
fi
sleep 1
"$GDB" -q xv6/kernel/kernel \
  -ex "target remote :$port" \
  -x "$gdb_file"
status=$?
cleanup
exit "$status"
