# xv6-riscv Operating System Customization Project

This repository documents an academic operating systems project completed at **IIT (ISM) Dhanbad, Department of Computer Science and Engineering**.  
The project is centered on **xv6-riscv**, a compact Unix-like teaching operating system used to understand core kernel design ideas in a practical way. Instead of only studying theory, the team extended xv6 by adding new system calls and kernel behaviors, and then verified the work through user-level test programs.

---

## Course and Team Information

- **Course:** Operating Systems Lab (NSCS210)  
- **Instructor:** Jaishree Mayank Mam

**Team Members**

- Prathamesh Vispute
- Pranjul
- Prathyush P
- Punit
- Poka Sireesha
- Prabir Soren

---

## Introduction

xv6 is intentionally small, but it still includes the most important operating system building blocks such as process creation, memory management, trap handling, and system calls. Because of this, it is a strong platform for learning how user-space requests are translated into kernel actions.

In this project, the base xv6 kernel was extended with functionality across multiple domains: process control, inter-process communication, scheduling, threading, and synchronization. The overall aim was to gain hands-on kernel programming experience while preserving the correctness and stability of the original system.

---

## Project Objectives

The report defines the following objectives, each of which guided implementation:

1. **Understand system call flow in xv6.**  
   The team studied the complete path from user program invocation to kernel dispatch and return, including syscall number mapping and argument handling.

2. **Implement new system calls for different OS features.**  
   The project adds APIs in multiple areas so that students can observe how different kernel subsystems are connected in practice.

3. **Modify kernel behavior safely.**  
   Changes were made in a way that keeps existing xv6 behavior functional, rather than replacing or breaking default mechanisms.

4. **Validate using user-space test programs.**  
   Each major addition was paired with executable test programs to demonstrate expected behavior.

5. **Learn practical synchronization and scheduling concepts.**  
   By implementing locks, semaphores, threads, and priorities, the project emphasizes concurrency control and CPU resource sharing.

---

## Implemented Features (Detailed)

### 1) Process Control: `waitpid(...)`

The project introduces `waitpid`, which allows a parent process to wait for a **specific** child process instead of waiting for any child generically, and to receive the child’s termination status through its status argument. This is useful when a parent creates multiple children and must coordinate completion in a controlled order. It also enables cleaner process lifecycle handling in programs that need targeted synchronization.

### 2) Shared Memory IPC: `shmget(int key)` and `shmdt(int key)`

To support inter-process communication, shared memory operations were added. `shmget` allows a process to create or access a memory segment associated with a key, while `shmdt` detaches that segment. These calls demonstrate how separate processes can exchange data efficiently through a common memory region rather than relying only on file-based or pipe-based communication.

### 3) Scheduling Extension: `setp(int pid, int priority)`

The scheduler was extended with process priority support. Using `setp`, a process priority can be modified, allowing experiments with how scheduling decisions change based on priority values. This implementation is educational and focuses on core behavior rather than advanced production scheduling policies.

### 4) Validation Syscall: `ismyear(void)`

`ismyear` returns a constant value (`1926`). In this project, it is used as a simple validation syscall to confirm that the full syscall path is wired correctly; the value itself is fixed for demonstration/testing rather than representing dynamic runtime logic.

### 5) Kernel Threads

The following thread APIs were added:

- `thread_create(void (*fcn)(void *), void *arg, void *stack)`
- `thread_join(int tid)`
- `thread_exit(int status)`
- `thread_id(void)`

These calls allow creation and management of lightweight execution units. They help demonstrate thread lifecycle handling, completion waiting, and identification, while exposing students to challenges around shared address spaces and concurrent execution.

### 6) Synchronization Primitives

Both mutex and semaphore interfaces were introduced:

- **Mutex:** `mutex_init(int id)`, `mutex_acquire(int id)`, `mutex_release(int id)`
- **Semaphore:** `sem_init(int id, int value)`, `sem_wait(int id)`, `sem_post(int id)`

These primitives are necessary to coordinate access to shared data and to prevent race conditions in multi-threaded or multi-process scenarios. Their inclusion connects theoretical synchronization topics directly to kernel-supported system call interfaces.

---

## Key Files Modified and Their Roles

According to the report, the following files were central to implementation:

- `kernel/proc.c`, `kernel/proc.h`  
  Updated for process/thread management behavior, scheduling-related logic, and control flow extensions needed by the new features.

- `kernel/syscall.c`, `kernel/syscall.h`  
  Modified to register newly added syscalls and map them to unique syscall numbers so user requests can be dispatched correctly.

- `kernel/sysproc.c`  
  Contains core kernel-side logic for several newly introduced process/system interfaces.

- `kernel/vm.c`  
  Adapted for memory-related requirements, especially shared memory support.

- `user/user.h`  
  Updated with user-visible function declarations so applications can call the new interfaces.

- `user/usys.pl`  
  Extended so user-space syscall stubs are generated for the added kernel calls.

- `Makefile`  
  Updated to ensure the new components and test programs are correctly compiled and linked into the xv6 build.

---

## Testing and Demonstration

The report lists these representative test programs:

- `test_ismyear`
- `test_priority`
- `waitpidtest`
- `shmtest`
- `test_thread`
- `synctest`

These tests are used to validate each major extension area. Together, they check syscall reachability, expected functionality, and behavior under concurrent execution scenarios.

---

## Challenges Faced During Development

1. **Understanding xv6 internals**  
   Even though xv6 is compact, kernel control flow can be difficult at first because process handling and syscall dispatch involve multiple linked files and structures.

2. **Cross-file syscall integration**  
   Implementing a syscall requires synchronized edits in declarations, syscall numbering, dispatch tables, and handler logic. Missing any one step can break the call chain.

3. **Kernel debugging constraints**  
   Kernel-space debugging is more difficult than user-space debugging, so careful tracing and iterative verification were necessary.

4. **Concurrency correctness**  
   Threading and synchronization features introduced race-condition risks that required disciplined lock/semaphore usage.

5. **Feature interaction complexity**  
   Integrating IPC, scheduling, threads, and synchronization in one kernel increased the risk of subtle conflicts between subsystems.

---

## Conclusion

This project successfully extends xv6-riscv across five major operating-system domains: process control, IPC, scheduling, threading, and synchronization. Beyond implementing new APIs, the work demonstrates how kernel modifications, syscall interfaces, and user-space validation must fit together as one coherent system. Overall, the project provides meaningful practical insight into system calls, concurrency control, process coordination, and kernel-level resource management.
