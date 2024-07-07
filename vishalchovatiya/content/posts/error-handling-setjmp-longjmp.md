---
title: "Error Handling : setjmp & longjmp"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "error-handling"
  - "longjmp"
  - "setjmp"
---

### Points To Catch

- As for the control flow: `setjmp` returns twice, and `longjmp` never returns.
- When you call `setjmp` for the first time, to store the environment, it returns zero,
- And then when you call `longjmp`, the control flow passes to return from `setjmp` with the value provided in the argument.
- Use cases are generally cited as "error handling", and "don't use these functions".

**Note:** `setjmp` needn't actually be functions; it may well be a macro. `longjmp` is a function, though.

Here's a little control flow example:

### [](https://github.com/VisheshPatel/Linux-System-Programming/blob/master/setjmp%20&%20longjmp%20Error%20Handling.md#example)Example

```c
#include <stdio.h>
#include <setjmp.h>

jmp_buf env;

void foo()
{
    longjmp(&env, 10);                      +---->----+
}                                           |         |
                                            |         |
int main()              (entry)---+         ^         V
{                                 |         |         |
    if(setjmp(&env) == 0)         | (= 0)   |         | (= 10)
    {                             |         ^         |
        foo();                    +---->----+         |
    }                                                 +---->----+
    else                                                        |
    {                                                           |
        return 0;                                               +--- (end)
    }
}
```

### [](https://github.com/VisheshPatel/Linux-System-Programming/blob/master/setjmp%20&%20longjmp%20Error%20Handling.md#important-notes)Important Notes:

- You cannot pass 0 to `longjmp`. If you do, 1 is returned by `setjmp`.
- You must not return from the function that called `setjmp` before the corresponding `longjmp`. In other words, `longjmp` must only be called above `setjmp` in the call stack.
- You cannot actually store the result of `setjmp`. If you want to return in several different ways, you can use a switch, though:

```c
    switch (setjmp(&env))
    {
    case 0:   // first call
    case 2:   // returned from longjmp(&env, 2)
    case 5:   // returned from longjmp(&env, 5)
    // etc.
    }
```
