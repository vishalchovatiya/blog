---
title: "Binary semaphore example between threads in C"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "binary-semaphore"
  - "binary-semaphore-example-between-threads-in-c"
  - "posix-semaphore"
  - "semaphore"
featuredImage: "/images/Binary-semaphore-example-between-threads-in-C.png"
---

Semaphore is a synchronization mechanism. In more words, semaphores are a technique for coordinating or synchronizing activities in which multiple processes compete for the same resources. There are 2 types of semaphores: Binary semaphores & Counting semaphores. But our focus would be on binary semaphore only. That too binary semaphore example between threads in C language specifically. If you are in search of semaphore between processes then see [this](/posts/semaphore-between-processes-example-in-c).

- As its name suggest **binary semaphore can have a value either 0 or 1**.
- It means **binary semaphore protect access to a SINGLE shared resource**.
- So the internal counter of the semaphore can only take the values 1 or 0.
- When a resource is available, the process in charge set the semaphore to 1 else 0.

### Example of Binary semaphore example between threads in C using [POSIX-semaphore](http://www.csc.villanova.edu/~mdamian/threads/posixsem.html)

```c
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>

int a, b;
sem_t sem;

void ScanNumbers(void *ptr){
    for (;;){
        printf("%s", (char *)ptr);
        scanf("%d %d", &a, &b);
        sem_post(&sem);
        usleep(100 * 1000);
    }
}

void SumAndPrint(void *ptr){
    for (;;){
        sem_wait(&sem);
        printf("%s %d\n", (char *)ptr, a + b);
    }
}

int main()
{
    pthread_t thread1;
    pthread_t thread2;

    char *Msg1 = "Enter Number Two No\n";
    char *Msg2 = "sum = ";

    /*
    int sem_init(
        sem_t *sem          // pointer to semaphore variable    ,
        int pshared         // If = 0: can be used in threads only, else in process,
        unsigned int value  // initial value of the semaphore counter
    );

    return value 0 on successful & -1 on failure
    */

    sem_init(&sem, 0, 0);   // Can also use `sem = sem_open( "SemaphoreName", O_CREAT, 0777, 0);`

    pthread_create(&thread1, NULL, (void *)ScanNumbers, (void *)Msg1);
    pthread_create(&thread2, NULL, (void *)SumAndPrint, (void *)Msg2);

    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);

    printf("Wait For Both Thread Finished\n");
    sem_destroy(&sem);      // Can also use `sem_unlink( "SemaphoreName");`

    return 0;
}
```

- `sem_init()` : Initialize semaphore
- `sem_destroy()` : releases all resources
- `sem_wait()` : Wait for the semaphore to acquire
- `sem_post()` : Release semaphore
- `sem_trywait()` : Only works when the caller does not have to wait
- `sem_getvalue()` : Reads the counter value of the semaphore
- `sem_open()` : Connects to, & optionally creates, a named semaphore( like `sem_init()` )
- `sem_unlink()` : Ends connection to an open semaphore & causes the semaphore to be removed when the last process closes it( like `sem_destroy()`)

### General pointers

- Semaphore's internal implementation is like memory-mapped file([mmap](/posts/mmap/))
- Two standards of semaphore mechanism
    1. **POSIX-semaphore**: `sem_init()`, `sem_destroy()`, `sem_wait()`, `sem_post()`, `sem_trywait()`, `sem_getvalue()`, `sem_open()`,`sem_unlink()`
    2. **System-V-semaphore**: `semget()`, `semop()`, `` `semctl()` ``
