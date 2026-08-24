# CSCI 4727 In-Class Demonstrations

This repository contains the instructor-facing, repeatable demonstrations for CSCI 4727. The xv6 trees are pinned submodules so a demo can be reproduced from a known source state.

Run `make help` for the available demonstrations. Each target prints the command it is about to run and points to the source and GDB command file that explain the demonstration.

## Layout

- `xv6-labs/`: pinned lab-oriented xv6 tree.
- `xv6-lecture/`: pinned lecture/demo xv6 tree.
- `demos/`: small standalone demo applications.
- `scripts/`: transparent orchestration and GDB command files.

The default runtime is a Linux host with QEMU and GDB installed. Demo scripts fail early with a useful message when a dependency or submodule is missing.
