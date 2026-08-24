#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void) {
  int pipefd[2];
  if (pipe(pipefd) == -1) return 1;
  pid_t child = fork();
  if (child == -1) return 1;
  if (child == 0) {
    close(pipefd[0]);
    dprintf(pipefd[1], "child: produced data through a file descriptor\n");
    close(pipefd[1]);
    _exit(0);
  }
  close(pipefd[1]);
  char buffer[128];
  ssize_t n = read(pipefd[0], buffer, sizeof buffer - 1);
  if (n < 0) return 1;
  buffer[n] = '\0';
  printf("parent: read from pipe: %s", buffer);
  close(pipefd[0]);
  waitpid(child, NULL, 0);
  puts("parent: wait completed");
  return 0;
}
