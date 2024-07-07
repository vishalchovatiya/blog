---
title: "Semaphore between processes example in C"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "posix-semaphore"
  - "semaphore"
  - "semaphore-between-process"
  - "semaphore-example-in-c"
featuredImage: "/images/Binary-semaphore-example-between-threads-in-C.png"
---

Semaphore is a synchronization mechanism. In more words, semaphores are a technique for coordinating or synchronizing activities in which multiple processes compete for the same resources. There are 2 types of semaphores: [Binary semaphores](/posts/binary-semaphore-example-between-threads-in-c/) & Counting semaphores. 

- **Binary Semaphores**: Only two states 0 & 1, i.e., locked/unlocked or available/unavailable, Mutex implementation.
- **Counting Semaphores**: Semaphores which allow arbitrary resource count called counting semaphores.

Here, we will see the POSIX style semaphore. POSIX semaphore calls are much simpler than the System V semaphore calls. However, System V semaphores are more widely available, particularly on older Unix-like systems. POSIX semaphores have been available on Linux systems post version 2.6 that use Glibc.

There are two types of POSIX semaphores: named & unnamed. The named semaphore(which internally implemented using shared memory) generally used between processes. As it creates shared memory system-wide & can use in multiple processes. But if you have threads only then, the unnamed semaphore will be the best choice.

### Semaphore between processes example in C using [POSIX-semaphore](http://www.csc.villanova.edu/~mdamian/threads/posixsem.html)

```c
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <sys/wait.h>

const char *semName = "asdfsd";

void parent(void){
    sem_t *sem_id = sem_open(semName, O_CREAT, 0600, 0);

    if (sem_id == SEM_FAILED){
        perror("Parent  : [sem_open] Failed\n"); return;
    }

    printf("Parent  : Wait for Child to Print\n");
    if (sem_wait(sem_id) < 0)
        printf("Parent  : [sem_wait] Failed\n");
    printf("Parent  : Child Printed! \n");
    
    if (sem_close(sem_id) != 0){
        perror("Parent  : [sem_close] Failed\n"); return;
    }

    if (sem_unlink(semName) < 0){
        printf("Parent  : [sem_unlink] Failed\n"); return;
    }
}

void child(void)
{
    sem_t *sem_id = sem_open(semName, O_CREAT, 0600, 0);

    if (sem_id == SEM_FAILED){
        perror("Child   : [sem_open] Failed\n"); return;        
    }

    printf("Child   : I am done! Release Semaphore\n");
    if (sem_post(sem_id) < 0)
        printf("Child   : [sem_post] Failed \n");
}

int main(int argc, char *argv[])
{
    pid_t pid;
    pid = fork();

    if (pid < 0){
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (!pid){
        child();
        printf("Child   : Done with sem_open \n");
    }
    else{
        int status;
        parent();
        wait(&status);
        printf("Parent  : Done with sem_open \n");
    }

    return 0;
}
```

- `sem_open() : Connects to, & optionally creates, a named semaphore( like `sem_init()`)
- `sem_unlink() : Ends connection to an open semaphore & causes the semaphore to be removed when the last process closes it( like `sem_destroy()`
- `sem_wait()` Wait for the semaphore to acquire
- `sem_post()` Release semaphore

### General pointers

- Semaphore's internal implementation is like memory-mapped file([mmap](/posts/mmap/))
- Two standards of semaphore mechanism
    1. **POSIX-semaphore**: `sem_init()`, `sem_destroy()`, `sem_wait()`, `sem_post()`, `sem_trywait()`, `sem_getvalue()`, `sem_open()`, `sem_unlink()`
    2. **System-V-semaphore**: `semget()`, `semop()`, `semctl()`
