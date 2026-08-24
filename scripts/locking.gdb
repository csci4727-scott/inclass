set pagination off
break acquire
commands
  silent
  printf "lock acquire: %s\\n", lk
  continue
end
break release
commands
  silent
  printf "lock release: %s\\n", lk
  continue
end
