set pagination off
echo Breakpoints: page-fault entry and lazy allocation\n
break usertrap
continue
echo Inspect scause, stval, and the current process page table.\n
