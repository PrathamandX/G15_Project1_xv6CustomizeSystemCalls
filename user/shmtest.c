#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int pid;
  char *buf;

  pid = fork();
  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
    // child
    buf = shmget(0);
    if(buf == 0){
      printf("child: shmget failed\n");
      exit(1);
    }

    while(buf[0] == 0)
      pause(1);

    printf("child read: %s\n", buf);

    strcpy(buf, "ack from child");

    shmdt(0);
    exit(0);
  }

  // parent
  buf = shmget(0);
  if(buf == 0){
    printf("parent: shmget failed\n");
    exit(1);
  }

  strcpy(buf, "hello from parent");

  wait(0);

  printf("parent sees after child: %s\n", buf);

  shmdt(0);
  exit(0);
}
