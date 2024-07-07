---
title: "Clone system call example"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "clone"
  - "clone-system-call-example"
  - "fork"
  - "system-call"
---

This is a quick article on Clone system call example without talking shit. So let's see some pointers for the same :

- `clone()` creates a [new process](/posts/program-gets-run-linux/), in a manner similar to [fork](/posts/create-process-using-fork). It is actually a library function layered on top of the underlying **`clone`**`()`system call.
- Unlike [fork](/posts/create-process-using-fork/) , these calls allow the child process to share parts of its execution context with the calling process, such as the memory space, the table of file descriptors, and the table of signal handlers.
- The main use of `clone()`is to implement threads: multiple threads of control in a program that run concurrently in shared memory space.
- When the child process is created with `clone()` it executes the function application _`fn`_`(`_`arg`_`)`. The _`fn`_ argument is a pointer to a function that is called by the child process at the beginning of its execution. The _`arg`_ argument is passed to the _`fn`_ function. When the _`fn`_`(`_`arg`_`)` function application returns, the child process terminates. The integer returned by _`fn`_ is the exit code for the child process. The child process may also terminate explicitly by calling [exit](http://man7.org/linux/man-pages/man3/exit.3.html) or after receiving a fatal signal.
- The child\_stack argument specifies the location of the stack used by the child process. Since the child and calling process may share a memory. It is not possible for the child process to execute in the same stack as the calling process. The calling process must, therefore, set up memory space for the child stack and pass a pointer to this space to **`clone`**`()` Stacks grow downwards on all processors that run Linux (except the HP PA processors). So _child\_stack_ usually points to the topmost address of the memory space set up for the child stack.
- There are some flags related to child/parent control, memory, tracing signals, etc which you can find on [man page](http://man7.org/linux/man-pages/man2/clone.2.html).

### Clone system call example

```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sched.h>
#include <signal.h>

#define STACK 8192

int do_something(){
        printf("Child pid : %d\n", getpid());
        return 0;
}

int main() {
        void *stack = malloc(STACK);    // Stack for new process

        if(!stack) {
                perror("Malloc Failed");
                exit(0);
        }

        if( clone( &do_something, (char *)stack + STACK, CLONE_VM, 0) < 0 ){
                perror("Clone Failed");
                exit(0);
        }

        printf("Parent pid : %d\n", getpid());

        sleep(1);       // Add sleep so we can she both processes output

        free(stack);

        return 0;
}
```
