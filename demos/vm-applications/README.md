# Virtual Memory for Applications Demo (Lecture 10)

A compact user-level VM demo: `sqrts[pos]` looks like a huge precomputed table, but only one page is mapped at a time.

## Files

- `sqrts.c` - demo code
- `Makefile` - build/run targets

## Run

```bash
cd /home/chandler/src/csci-4727/course/content/inclass/vm-applications
make
make run
```

## What to say while running

### 1) Setup path (`setup_sqrt_region`)

- Reserve a large VA range with `mmap(..., PROT_NONE)` to pick a safe base pointer `sqrts`.
- Immediately `munmap` it so no large mapping stays resident.
- Set `RLIMIT_AS` to a small cap (8 MiB) so the process cannot map the full table.
- Register `SIGSEGV` handler with `SA_SIGINFO`.

### 2) Fault path (`handle_sigsegv`)

On `sqrts[pos]` access:

- Fault address is rounded down to page base.
- Previous mapped page is unmapped so the demo keeps about one page resident.
- Faulting page is mapped with `mmap(..., MAP_FIXED, PROT_READ|PROT_WRITE)`.
