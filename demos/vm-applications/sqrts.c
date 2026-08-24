#define _GNU_SOURCE
#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <unistd.h>

static size_t page_size;

// align_down - rounds a value down to an alignment
// @x: the value
// @a: the alignment (must be power of 2)
#define align_down(x, a) ((x) & ~((typeof(x))(a) - 1))

#define AS_LIMIT  (1 << 23)  // Virtual-address-space byte limit for the demo
#define MAX_SQRTS (1 << 27)  // Maximum number of sqrt table entries

static double *sqrts;
static int nfault;

static void calculate_sqrts(double *sqrt_pos, int start, int nr)
{
  for (int i = 0; i < nr; i++) {
    sqrt_pos[i] = sqrt((double)(start + i));
  }
}

static void handle_sigsegv(int sig, siginfo_t *si, void *ctx)
{
  (void)sig;
  (void)ctx;

  uintptr_t fault_addr = (uintptr_t)si->si_addr;
  double *page_base = (double *)align_down(fault_addr, page_size);
  static double *last_page_base = NULL;

  if (last_page_base && munmap(last_page_base, page_size) == -1) {
    fprintf(stderr, "Couldn't munmap(); %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  if (mmap(page_base, page_size, PROT_READ | PROT_WRITE,
           MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0) == MAP_FAILED) {
    fprintf(stderr, "Couldn't mmap(); %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  nfault++;
  calculate_sqrts(page_base, (int)(page_base - sqrts),
                  (int)(page_size / sizeof(double)));
  last_page_base = page_base;
}

static void setup_sqrt_region(void)
{
  struct rlimit lim = {AS_LIMIT, AS_LIMIT};
  struct sigaction act;

  // Temporary mapping only used to pick a safe virtual range for sqrts.
  sqrts = mmap(NULL, MAX_SQRTS * sizeof(double) + AS_LIMIT, PROT_NONE,
               MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (sqrts == MAP_FAILED) {
    fprintf(stderr, "Couldn't mmap() region for sqrt table; %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  // Release it so we stay under RLIMIT_AS until pages are faulted in.
  if (munmap(sqrts, MAX_SQRTS * sizeof(double) + AS_LIMIT) == -1) {
    fprintf(stderr, "Couldn't munmap() region for sqrt table; %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  if (setrlimit(RLIMIT_AS, &lim) == -1) {
    fprintf(stderr, "Couldn't set rlimit on RLIMIT_AS; %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  act.sa_sigaction = handle_sigsegv;
  act.sa_flags = SA_SIGINFO;
  sigemptyset(&act.sa_mask);
  if (sigaction(SIGSEGV, &act, NULL) == -1) {
    fprintf(stderr, "Couldn't set up SIGSEGV handler; %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
}

static void test_sqrt_region(void)
{
  struct timeval start, end;

  printf("sqrts-demo: validating table values...\n");
  srand(0xDEADBEEF);
  gettimeofday(&start, NULL);

  for (int i = 0; i < 1000; i++) {
    int pos = rand() % (MAX_SQRTS - 1);
    double correct_sqrt;
    calculate_sqrts(&correct_sqrt, pos, 1);
    if (sqrts[pos] != correct_sqrt) {
      fprintf(stderr, "Square root is incorrect. Expected %f, got %f.\n",
              correct_sqrt, sqrts[pos]);
      exit(EXIT_FAILURE);
    }
  }

  gettimeofday(&end, NULL);

  long secs_used = (long)(end.tv_sec - start.tv_sec);
  long micros_used = (secs_used * 1000000L) +
                     (long)end.tv_usec -
                     (long)start.tv_usec;

  printf("sqrts-demo: page_size=%zu bytes\n", page_size);
  printf("sqrts-demo: elapsed=%ld us faults=%d\n", micros_used, nfault);
  printf("sqrts-demo: validation passed\n");
}

int main(void)
{
  page_size = (size_t)sysconf(_SC_PAGESIZE);
  setup_sqrt_region();
  test_sqrt_region();
  return 0;
}
