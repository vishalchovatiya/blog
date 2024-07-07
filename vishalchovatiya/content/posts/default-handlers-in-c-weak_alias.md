---
title: "Default Handlers in C: weak_alias"
date: "2019-09-15"
categories: 
  - "c-language"
  - "cpp"
tags: 
  - "weak-symbols"
  - "weak_alias"
---

Default Handlers in C: weak\_alias function tells the linker that `new` is to be a weak alias for  `old`. That is, this definition of `new` is a [weak symbol](https://en.wikipedia.org/wiki/Weak_symbol). If there is no other definition of a symbol called `new`, this `old` definition stands.

Might seems alien to you first, so go through a below example & read again.

- Definition of `weak_alias` is as follows :

```c
#define weak_alias(old, new) \
        extern __typeof(old) new __attribute__((weak, alias(#old)))
```

- If there is another (non-weak) definition of `new` then that non-weak(i.e. strong) definition stands and the weak definition is ignored.

### Let's understand default handlers in C: weak\_alias by example

#### oldDef.c

```c
#define weak_alias(old, new) \
        extern __typeof(old) new __attribute__((weak, alias(#old)))


void DefaultHandler()
{
        puts("Default Handler");
}

weak_alias( DefaultHandler, Feature1);
```

#### weak.c

```c
#include<stdio.h>

/*
void Feature1()
{
        puts("Feature 1");
}
*/

int main()
{
        Feature1();
        DefaultHandler();

        return 0;
}

```

#### Compilation

```bash
$ gcc weak.c oldDef.c -o weak
$ ./weak
```

- If you run the above program as it is, it will print

```bash
Default Handler
Default Handler
```

- But if you uncomment `Feature1()`then it will print

```bash
Default Handler
Feature 1
```

- Why so? It's due to way linker understand symbols. When you first run without `Feature1()`function linker does not found strong `Feature1()`symbol so it links to `DefaultHandler()` And in the second case,  when we introduce `Feature1()`linker finds a strong symbol & links it to `Feature1()`
