#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int st;
  int p1, p2, p3;
  int r;

  p1 = fork();
  if(p1 == 0){
    pause(20);
    exit(11);
  }

  p2 = fork();
  if(p2 == 0){
    pause(5);
    exit(22);
  }

  p3 = fork();
  if(p3 == 0){
    pause(10);
    exit(33);
  }

  printf("Parent waiting specifically for child pid = %d\n", p3);
  r = waitpid(p3, &st);
  printf("waitpid returned pid = %d, status = %d\n", r, st);

  printf("Now collecting remaining children using wait()\n");
  while(wait(&st) > 0){
    printf("wait collected one child, status = %d\n", st);
  }

  exit(0);
}
