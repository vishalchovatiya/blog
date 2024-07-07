---
title: "Create Process Using fork()"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "fork"
  - "process"
---

### **Points To Catch**

- When we fork in any process it simply creates a copy of the same process which we call child process

```bash
                    Parent          Child
    return          PID             0            

```

Fork returns 0 in the child process & PID of the child process in the parent process, which you can see in above example. returns -1 on failer.

-  Create copy of process including memory variables & stored value in it with its own address space

### **Example 1**

```c
#include <stdio.h>
#include <unistd.h>

int main(void)
{
        pid_t pid = fork();

        if( pid > 0 )
                printf("Parent Process: ParentPID = %d, ChildPID  = %d\n", getpid(), pid);
        else
                printf("Child  Process: ChildPID  = %d, ParentPID = %d\n", getpid(), pid);

        sleep(2);

        return 0;
}
```

### **Output**

```bash
Parent Process: ParentPID = 2640, ChildPID  = 2641
Child  Process: ChildPID  = 2641, ParentPID = 0
```

### Example 2

#### **How many process this program create?**

```c
#include <unistd.h>

int main(void) {

        int i;

        for (i = 0; i < 3; i++) {
                if (fork() && (i == 1)) {
                        break;
                }
        }
}
```

**Answer** = 6

#### **Explanation** :

- In Parent process(P), i = 0. we create 1 child process(C1), both entering the loop at i = 1. Total = 2 processes.
- In Parent(P) & Child(C1) process, i = 1. Both of those processes fork & let say create C2 & C3, but none of them continue to iterate because of the `if (fork() && (i == 1)) break;` line. Total = 4 processes, but only two of those are continuing to loop.
- In Child(C2) & Child(C3) process, i = 2. Both fork & let say create C4 & C5, resulting in 6 processes.
- In Child(C4) & Child(C5) process, i = 3. Exit the loop (since i < 3 == false , there is no more looping)
