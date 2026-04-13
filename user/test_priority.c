#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int st;
  int i;

  if(fork() == 0){
    setp(getpid(), 10);
    for(i = 0; i < 50000000; i++);
    pause(20);
    printf("Child with priority 10 finished\n");
    exit(0);
  }

  if(fork() == 0){
    setp(getpid(), 50);
    for(i = 0; i < 50000000; i++);
    pause(10);
    printf("Child with priority 50 finished\n");
    exit(0);
  }

  if(fork() == 0){
    setp(getpid(), 100);
    for(i = 0; i < 50000000; i++);
    printf("Child with priority 100 finished\n");
    exit(0);
  }

  wait(&st);
  wait(&st);
  wait(&st);
  exit(0);
}
