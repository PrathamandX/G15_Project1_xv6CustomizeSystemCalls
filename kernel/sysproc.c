#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#define NKMUTEX 16
#define NKSEM 16

struct kmutex {
  int used;
  int locked;
  struct spinlock lk;
};

struct ksem {
  int used;
  int count;
  struct spinlock lk;
};

static struct kmutex kmutexes[NKMUTEX];
static struct ksem ksems[NKSEM];

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_waitpid(void)
{
  int pid;
  uint64 addr;

  argint(0, &pid);
  argaddr(1, &addr);

  return kwaitpid(pid, addr);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_shmget(void)
{
  int key;
  argint(0, &key);
  return kshmget(key);
}

uint64
sys_shmdt(void)
{
  int key;
  argint(0, &key);
  return kshmdt(key);
}

//synchornization 
uint64
sys_mutex_init(void)
{
  int id;

  argint(0, &id);
  if(id < 0 || id >= NKMUTEX)
    return -1;

  if(kmutexes[id].used == 0){
    initlock(&kmutexes[id].lk, "kmutex");
    kmutexes[id].used = 1;
  }

  acquire(&kmutexes[id].lk);
  kmutexes[id].locked = 0;
  release(&kmutexes[id].lk);

  return 0;
}

uint64
sys_mutex_acquire(void)
{
  int id;

  argint(0, &id);
  if(id < 0 || id >= NKMUTEX || kmutexes[id].used == 0)
    return -1;

  acquire(&kmutexes[id].lk);
  while(kmutexes[id].locked){
    if(killed(myproc())){
      release(&kmutexes[id].lk);
      return -1;
    }
    sleep(&kmutexes[id], &kmutexes[id].lk);
  }
  kmutexes[id].locked = 1;
  release(&kmutexes[id].lk);

  return 0;
}

uint64
sys_mutex_release(void)
{
  int id;

  argint(0, &id);
  if(id < 0 || id >= NKMUTEX || kmutexes[id].used == 0)
    return -1;

  acquire(&kmutexes[id].lk);
  if(kmutexes[id].locked == 0){
    release(&kmutexes[id].lk);
    return -1;
  }

  kmutexes[id].locked = 0;
  wakeup(&kmutexes[id]);
  release(&kmutexes[id].lk);

  return 0;
}

//new setp function
uint64
sys_setp(void)
{
  int pid, priority;

  argint(0, &pid);
  argint(1, &priority);

  return setpriority(pid, priority);
}
//new ismyear function

uint64
sys_ismyear(void)
{
  return 1926;
}

uint64
sys_sem_init(void)
{
  int id, value;

  argint(0, &id);
  argint(1, &value);

  if(id < 0 || id >= NKSEM || value < 0)
    return -1;

  if(ksems[id].used == 0){
    initlock(&ksems[id].lk, "ksem");
    ksems[id].used = 1;
  }

  acquire(&ksems[id].lk);
  ksems[id].count = value;
  release(&ksems[id].lk);

  return 0;
}

uint64
sys_sem_wait(void)
{
  int id;

  argint(0, &id);
  if(id < 0 || id >= NKSEM || ksems[id].used == 0)
    return -1;

  acquire(&ksems[id].lk);
  while(ksems[id].count == 0){
    if(killed(myproc())){
      release(&ksems[id].lk);
      return -1;
    }
    sleep(&ksems[id], &ksems[id].lk);
  }
  ksems[id].count--;
  release(&ksems[id].lk);

  return 0;
}

uint64
sys_sem_post(void)
{
  int id;

  argint(0, &id);
  if(id < 0 || id >= NKSEM || ksems[id].used == 0)
    return -1;

  acquire(&ksems[id].lk);
  ksems[id].count++;
  wakeup(&ksems[id]);
  release(&ksems[id].lk);

  return 0;
}

uint64
sys_thread_create(void)
{
  uint64 fcn, arg, stack;

  argaddr(0, &fcn);
  argaddr(1, &arg);
  argaddr(2, &stack);

  printf("sys_thread_create: fcn=%lx arg=%lx stack=%lx\n", fcn, arg, stack);

  return kthread_create(fcn, arg, stack);
}

uint64
sys_thread_join(void)
{
  int tid;
  argint(0, &tid);
  return kthread_join(tid);
}

uint64
sys_thread_exit(void)
{
  int status;
  argint(0, &status);
  kthread_exit(status);
  return 0;
}

uint64
sys_thread_id(void)
{
  return kthread_id();
}
