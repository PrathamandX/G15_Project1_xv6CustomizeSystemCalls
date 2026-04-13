#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int mutex = 0;   // mutex ID

  if(mutex_init(mutex) < 0){
    printf("mutex_init failed\n");
    exit(1);
  }

  for(int i = 0; i < 5; i++){
    int pid = fork();
    if(pid == 0){
      for(int j = 0; j < 10; j++){   // keep small first
        mutex_acquire(mutex);
        printf("child %d increment %d\n", getpid(), j);
        mutex_release(mutex);
      }
      exit(0);
    }
  }

  for(int i = 0; i < 5; i++)
    wait(0);

  printf("Test completed\n");
  exit(0);
}
