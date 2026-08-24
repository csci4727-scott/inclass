.PHONY: help demo-overview demo-network demo-isolation demo-ebpf demo-vm-faults demo-uservm demo-blocked-reader demo-locking demo-scheduling demo-filesystem demo-crash-recovery

XV6 := xv6

help:
	@printf '%s\n' 'Targets: demo-overview demo-network demo-isolation demo-ebpf demo-vm-faults demo-uservm demo-blocked-reader demo-locking demo-scheduling demo-filesystem demo-crash-recovery'
	@printf '%s\n' 'Each target prints its source and automation files before running.'

demo-overview:
	./scripts/overview-demo.sh

demo-network:
	./scripts/network-demo.sh

demo-isolation:
	./scripts/isolation-demo.sh

demo-ebpf:
	./scripts/ebpf-demo.sh

demo-vm-faults:
	./scripts/run-xv6-demo.sh "raw and lazy page faults" scripts/vm-faults.gdb

demo-uservm:
	$(MAKE) -C demos/vm-applications
	@printf '%s\n' 'Inspect demos/vm-applications/sqrts.c and scripts/run-xv6-demo.sh.'

demo-blocked-reader:
	./scripts/run-xv6-demo.sh "blocked reader and interrupt wakeup" scripts/blocked-reader.gdb

demo-locking:
	./scripts/run-xv6-demo.sh "lock contention" scripts/locking.gdb

demo-scheduling:
	./scripts/run-xv6-demo.sh "scheduler state transitions" scripts/scheduling.gdb

demo-filesystem:
	./scripts/run-xv6-demo.sh "pathname lookup and file metadata" scripts/filesystem.gdb

demo-crash-recovery:
	./scripts/run-xv6-demo.sh "journal commit and recovery" scripts/crash-recovery.gdb
