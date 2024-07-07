---
title: "CRT: C Run Time Before Starting main()"
date: "2016-09-10"
categories: 
  - "c-language"
  - "cpp"
tags: 
  - "c-runtime"
  - "crt0-o"
  - "crtbegin-s"
  - "entry-point"
---

There are a lot of functions called before & after the main execution. As an application developer you need not worry about this stuff, but yes! if you are a core developer who works in Linux kernel, Binutils, compiler or embedded system-related development, then you must know these things. Here in "CRT: C run time before starting main", we will see some pointers related to it.

### What Is [crt](https://en.wikipedia.org/wiki/Crt0)?

- crt stands for C runtime.
- crt is a set of execution startup routines compiled into a program which performs any initialization work required before calling the program's main function. It is a basic runtime library/system.
- The work performed by crt depends on the ABI, machine, compiler, operating system and C standard library implementation.

### CRT: C Run Time Before Starting main()

When an executable is loaded in the memory, the control does not immediately jump into `main()`[here](/posts/program-gets-run-linux/) is what happen). Before going to `main` it goes to an intermediate start-up-routine/symbol(first symbol) called `_start` which does some setup/initialization work like:

- Initialize the stacks.
- Preparing the `stdin` / `stdout` / `stderr` streams;
- Pushing argc and argv (or whatever arguments are provided by the shell) onto the stack so that `main()`can find them.
- If required, copy the contents of the `.data` (initialized data) section from non-volatile memory.
- If required, copy the contents of the `.fast` section from non-volatile memory to SRAM.
- Initialize the `.bss` section to zero.
- Initialize the heap.
- Any other kind of preparation the OS or hardware might require.
- Call the `main` entry point.

The shutdown/cleanup code (that makes sure that `exit()` is called when `main()`returns) is defined in a specific object file commonly called `crt0.o` . Other possible names are `crt1.o`(`/usr/lib/crt1.o` – used if ctors/dtors are there) or similar.

### Typical Runtime files

| File | Detail |
|------|--------|
| crt0.o | Will contain the _start function that initializes the process |
| crtbegin.o | GCC uses this to find the start of the constructors(init). |
| crtend.o | GCC uses this to find the start of the destructors(fini). |
| crti.o | Header of init & fini (for push in stack) |
| crtn.o | Footer of init & fini (for pop in the stack) |
| Scrt1.o | Used in place of crt1.o when generating PIE( position independent executable). |

- There could be `crt1.o`, `crt2.o` & so on, depending upon implementation, `crt0.c` is runtime 0 & runs first.
- glibc calls this file `start.S` while uClibc calls this `crt0.S` or `crt1.S`
- General linking order is **crt1.o crti.o crtbegin.o \[-L paths\] \[user objects\] \[gcc libs\] \[C libs\] \[gcc libs\] crtend.o crtn.o**.

### What Is the Need for C Startup Routine?

Calling `main()` is a C thing while calling `_start()`is a kernel thing, indicated by the entry point in the binary format header. (for clarity: the kernel doesn't want or need to know that we call it `_start`).

### Why Doesn’t a Compiler Give the Address of Main() as a Starting Point?

That’s because typical libc implementations want to do some initializations before really starting the program.

### Changing Entry Point

```bash
$ cat centrypoint.c
int disp() { printf("Display !\n"); exit(0); }
int main() { printf("not called\n"); }
$ gcc centrypoint.c -e disp
$ ./a.out
Display !
```

Some compiler uses `--entry` or `-Wl,-edisp`. The `-Wl,...` thing passes arguments to the linker, and the linker takes a `-e` argument to set the entry function

### Flow of x86 C Program With Runtime

| Routine | File |
|---------|------|
| _init & _fini(push) | ./crt/x86_64/crti.s |
| _start | ./arch/x86_64/crt_arch.h |
| _start_c | ./crt/crt1.c |
| __libc_start_main | ./src/env/__libc_start_main.c |
| main | Our Program |
| exit | Close process |
| _init & _fini(pop) | ./crt/x86_64/crtn.s |
