#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' 'Step 1: the shell exposes files, processes, and pipes.'
printf 'alpha\nbeta\n' | wc -l
printf '%s\n' 'Step 2: fork/exec/wait/pipe are visible in the source below.'
sed -n '1,220p' demos/overview/process-pipeline.c
printf '%s\n' 'Step 3: compile and run the same composition.'
cc -Wall -Wextra -O0 -g demos/overview/process-pipeline.c -o /tmp/csci4727-process-pipeline
/tmp/csci4727-process-pipeline
