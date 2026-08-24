#!/usr/bin/env bash
set -euo pipefail

name=${1:?demo name required}
gdb_file=${2:?GDB command file required}

if [[ ! -d xv6-lecture/.git && ! -f xv6-lecture/Makefile ]]; then
  echo "xv6-lecture is not initialized; run git submodule update --init --recursive" >&2
  exit 2
fi
command -v qemu-system-riscv64 >/dev/null || { echo "qemu-system-riscv64 is required" >&2; exit 2; }
command -v riscv64-unknown-elf-gdb >/dev/null || { echo "riscv64-unknown-elf-gdb is required" >&2; exit 2; }

echo "==> Demo: $name"
echo "==> GDB commands: $gdb_file"
echo "==> Open the corresponding xv6 kernel source before continuing."
echo "==> Running: make -C xv6-lecture qemu-gdb"
exec make -C xv6-lecture qemu-gdb GDBCMD="$(pwd)/$gdb_file"
