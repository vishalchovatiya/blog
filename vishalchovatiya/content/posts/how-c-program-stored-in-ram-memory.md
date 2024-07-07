---
title: "How C Program Stored in Ram Memory!"
date: "2019-09-16"
categories: 
  - "c-language"
  - "cpp"
tags: 
  - "data-segment"
  - "heap-segment"
  - "stack-segment"
  - "text-segment"
  - "unmapped-or-reserved-segment"
cover:
    image: /images/How-C-program-stored-in-RAM-memory.png
---

When you run any C-program, its executable image loaded into RAM of computer in an organized manner which called process address space or memory layout of C program. Here I have tried to show you the same thing in two parts . In the 1st part i.e. "Overview", we will see segment-wise overview & in 2nd part i.e. "Example", we'll see How C program stored in RAM memory? with example.

The memory layout of C program organized in the following fashion:

- Text segment
- Data segment
- Heap segment
- Stack segment

Note: It's not just these 4 segments, there are a lot more but these 4 are the core to understanding the working of C program at the machine level.

```
        HIGHER  ADDRESS                                                                                                        
   +------------------------+                                                                             
   |  Unmapped or reserved  | Command-line argument & Environment variables                                                                          
   |------------------------|------------------------ 
   |     Stack segment      | |                                                                                                
   |           |            | | Stack frame                                                                                    
   |           v            | v                                                                                                
   |                        |                                                                                                  
   |           ^            | ^                                                                                                
   |           |            | | Dynamic memory                                                                                 
   |     Heap segment       | |                                                                                                
   |------------------------|------------------------ 
   |   Uninitialized data   |                                                                                                  
   |------------------------| Data segment                                                                                     
   |    Initialized data    |                                                                                                  
   |------------------------|------------------------ 
   |                        |                                                                                                  
   |      Text segment      | Executable code                                                                                  
   |                        |                                                                                                  
   +------------------------+                                                                                                  
         LOWER  ADDRESS                     
```

### Text segment

- Text segment contains executable instructions of your C program, its also called code segment also.
- This includes all functions making up the program(`main()`too), both user-defined and system.
- The text segment is sharable so that only a single copy needs to be in memory for different executing programs, such as text editors, shells, and so on.
- Usually, the text segment is read-only, to prevent a program from accidentally modifying its instructions.

### Data segment 

There are two subsections of this segment

#### Initialized data

- It contains both static and global data that initialized with non-zero values.
- This segment can be further classified into the read-only area and read-write area.
- For example, The global string defined by `char string[ ] = "hello world"` and a statement like an `int count=1` outside the `main` (i.e. global) would be stored in initialized read-write area.
- And a global statement like `const int A=3;` makes the variable `A` read-only and to be stored in initialized read-only area.

#### Uninitialized data (BSS segment)

- An uninitialized data segment also called the BSS( 'Block Started by Symbol' ) segment. Which contains all global and static variables that initialized to zero or do not have explicit initialization in source code.
- For example, The global variable declared as `int A` would be stored in the uninitialized data segment. A statement like static `int X=0` will also be stored in this segment cause it initialized with zero.
- If you do not initialize a global variable, by default value is zero. This flushing memory content is usually done by program loader(i.e. `/lib/ld-linux.so.2`).

### Heap segment

- The heap segment is an area where dynamically allocated memory (allocated by `malloc(), `calloc(), `realloc()`and `new` for C++) resides.
- When we allocate memory through dynamic allocation techniques(in other words, run-time memory allocation), program acquire space from OS and process address space grows.
- We can free dynamically allocated memory space (by using `free()`or `delete`). Freed memory goes back to the heap but doesn’t have to be returned to OS (it doesn't have to be returned at all), so unordered `malloc`/`free` eventually, cause heap fragmentation. You can learn more about how malloc works [here](/posts/free-malloc-work-c/).
- When we use dynamic allocation to acquire memory space we must keep track of allocated memory by using its address.

### Stack segment

- The stack segment is an area where local variables stored. By saying local variable means that all those variables which are declared in every function including `main()`in your C program. I have written a detailed article about the stack frame [here](/posts/how-c-program-stored-in-ram-memory/).
- When we call any function, the stack frame created and when a function returns, the stack frame destroyed/rewind including all local variables of that particular function.
- A stack frame contains some data like return address, arguments passed to it, local variables, and any other information needed by the invoked function.  
- A stack pointer(SP) which is a special function register of CPU keeps track of stack by each push & pop operation onto it, by adjusted stack pointer to next or previous address.
- The direction of the stack & heap growth completely depends on the compiler, ABI, OS and hardware.

We have taken a simple example as above along with its memory layout.

As we discussed in the previous tab(i.e. Overview) how executable image of our program divided into the different segment and stored in memory(RAM). Now we understand those blocks by using our example code presented above.

### Loader

- A loader is not a segment but kind of program interpreter which reads a different segment from the binary & copy it in RAM in proper fashion.
- There is a binary utility command by which you can see different segments & path of the loader in binary as follows:

```bash
$ readelf --segments ./a.out 

Elf file type is EXEC (Executable file)
Entry point 0x8048300
There are 9 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x08048034 0x08048034 0x00120 0x00120 R E 0x4
  INTERP         0x000154 0x08048154 0x08048154 0x00013 0x00013 R   0x1
      [Requesting program interpreter: /lib/ld-linux.so.2]
  LOAD           0x000000 0x08048000 0x08048000 0x00608 0x00608 R E 0x1000
  LOAD           0x000f08 0x08049f08 0x08049f08 0x00118 0x00124 RW  0x1000
  DYNAMIC        0x000f14 0x08049f14 0x08049f14 0x000e8 0x000e8 RW  0x4
  NOTE           0x000168 0x08048168 0x08048168 0x00020 0x00020 R   0x4
  GNU_EH_FRAME   0x0004c4 0x080484c4 0x080484c4 0x00044 0x00044 R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x10
  GNU_RELRO      0x000f08 0x08049f08 0x08049f08 0x000f8 0x000f8 R   0x1

 Section to Segment mapping:
  Segment Sections...
   00     
   01     .interp 
   02     .interp .note.ABI-tag .hash .dynsym .dynstr .gnu.version .gnu.version_r .rel.dyn .rel.plt .init .plt .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame 
   03     .init_array .fini_array .jcr .dynamic .got .got.plt .data .bss 
   04     .dynamic 
   05     .note.ABI-tag 
   06     .eh_frame_hdr 
   07     
   08     .init_array .fini_array .jcr .dynamic .got 

```

- As I have mentioned earlier, there is not only 4 segment as you can see above, but there are a lot of segments which usually depends on compiler & [ABI](https://en.wikipedia.org/wiki/Application_binary_interface).
- Above you can see, `.data`, `.bss`, `.text`, etc. segments are there. But a stack segment is not shown as its created at a run time & decided by OS(precisely loader & kernel).
- `INTERP` in the program header defines the name & path of loader which going to load the current binary image into the RAM by reading these segments. Here it is `/lib/ld-linux.so.2`.
- You can read more about binary file format ELF [here](/posts/understand-elf-file-format/).

### Text segment

When you compile C code, you get executable image(which may be in any form like `.bin`, `.exe`, `.hex`, `.out` or no extension etc). This executable image contains text segment which you see by Binutils command `$ objdump -d <binary_name>` and it looks like follows:

```bash
.....
080483f1 <main>:
 80483f1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 80483f5:	83 e4 f0             	and    $0xfffffff0,%esp
 80483f8:	ff 71 fc             	pushl  -0x4(%ecx)
.....
```

This is executable instructions stored in the text segment as a read-only section and shared by the processes if requires. These instructions read by CPU using program counter and stack frame created in the stack at the time of execution. Program-counter points to the address of the instruction to executed which lies in the text segment.

### Data segment

#### Initialized Data segment

- A `const int x = 1;` stored in the read-only area. So you can not modify it accidentally.
- While a string `char str[] = "Hi!";` & `static int var = 0;` stored in the read-write area because we don't use a keyword like const which makes variable read-only.

#### Uninitialized Data segment

- In our program, `int i` declared global goes to this area of storage because it is not initialized or initialized to zero by default.

### Heap segment

- When you compile your program, memory space allocated by you i.e. all locals, static & global variables fixed at compile-time. But when code needs memory at run-time, it approach OS by calling functions like `malloc(), `calloc(), etc.
- When OS provides dynamic memory to process it shrinks stack limit pointer which initially points to uninitialized data segment start(the technical word is "program break", read about it [here](/posts/how-do-malloc-free-work-in-c/)).
- As a result heap segment grows. That's why there is no line between heap & stack segment. An arrow indicates its growth of direction.
- In the example code, we allocate 1-byte dynamic memory using `malloc()`function and stored its address in pointer `ptr` to keep track of that memory or to access it.
- This `ptr` is a local variable of main hence it's in main's stack frame, but memory pointed by it is in a heap which I have shown by `*ptr`.

### Stack segment

- The usual starting point(not entry point which is different) of any program is `main(), which is also a function hence, stack frame is created for it while execution. Although there are many functions called before main which I have discussed [here](/posts/before-starting-main-c-runtime/).
- As you can see in image, stack frame of `main()` is created before function `func()`as we called it nested.
- As the `func( )` execution overs its local variable `a` and its stack frame will destroy(rewind is a precise word here), same goes for `main()`function also.
- And this is how stack grows & shrinks.

### FAQs

**Q. How do you determine the stack growth direction**

**A.** Simple...! by comparing the address of two different function's local variables.

```c
int *main_ptr = NULL;
int *func_ptr = NULL;

void func() { int a; func_ptr = &a; }

int main()
{
    int a; main_ptr = &a;

    func();

    (main_ptr > func_ptr) ? printf("DOWN\n") : printf("UP\n");

    return 0;
}
```

**Q. How do you corrupt stack deliberately**

**A.** Corrupt the SFR values stored in the stack frame.

```c
void func()
{
    int a;
    memset(&a, 0, 100); // Corrupt SFR values stored in stack frame
}

int main()
{
    func();
    return 0;
}

```

**Q. How you can increase stack frame size**

**A.** `alloca()`is the answer. Google about it or see [this](http://man7.org/linux/man-pages/man3/alloca.3.html).
