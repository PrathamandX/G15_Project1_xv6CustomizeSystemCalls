#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int y = ismyear();
  printf("ismyear returned: %d\n", y);
  exit(0);
}
