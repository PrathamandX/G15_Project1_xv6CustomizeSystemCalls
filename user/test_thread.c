#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NTHREADS 4
#define STACKSZ  4096
#define ITERS    2000

volatile int counter = 0;
int lockid;

void
worker(void *arg)
{
  int id = (int)(uint64)arg;
  int i;

  for(i = 0; i < ITERS; i++){
    mutex_acquire(lockid);
    counter++;
    mutex_release(lockid);
  }

  printf("thread %d tid=%d finished\n", id, thread_id());
  thread_exit(id);
}

int
main(void)
{
  int tids[NTHREADS];
  char *stacks[NTHREADS];
  int i, ret;

  lockid = mutex_init(0);

  printf("creating %d threads\n", NTHREADS);

  for(i = 0; i < NTHREADS; i++){
    stacks[i] = malloc(STACKSZ);
    if(stacks[i] == 0){
      printf("malloc failed\n");
      exit(1);
    }

    tids[i] = thread_create(worker, (void *)(uint64)i, stacks[i]);
    if(tids[i] < 0){
      printf("thread_create failed\n");
      exit(1);
    }

    printf("spawned thread %d with tid=%d\n", i, tids[i]);
  }

  for(i = 0; i < NTHREADS; i++){
    ret = thread_join(tids[i]);
    printf("joined tid=%d exit=%d\n", tids[i], ret);
    free(stacks[i]);
  }

  printf("final counter = %d expected = %d\n", counter, NTHREADS * ITERS);

  exit(0);
}
