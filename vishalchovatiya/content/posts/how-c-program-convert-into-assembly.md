---
title: "How C Program Converts Into Assembly!"
date: "2019-09-16"
categories: 
  - "c-language"
  - "cpp"
tags: 
  - "accessing-global-local-static-variables-in-c"
  - "function-prologue-epilogue"
  - "function-stack-frame"
  - "how-c-program-converts-into-assembly"
  - "how-do-you-corrupt-stack-deliberately"
  - "how-do-you-determine-the-stack-growth-direction"
  - "how-you-can-increase-stack-frame-size"
  - "return-value-from-function-in-c"
  - "x86-special-function-registers"
cover:
    image: /images/How-C-program-converted-into-assembly.png
---

In an earlier article, we have seen [C runtime: before starting main](/posts/before-starting-main-c-runtime/) & [How C program stored in RAM memory](/posts/how-c-program-stored-in-ram-memory/). Here we will see "How C program converts into assembly?" and different aspect of its working at the machine level.

## A Bit About Functions Stack Frames

- During function code execution, a new stack frame is created in stack memory to allow access to function parameters and local variables.
- The direction of stack frame growth totally depends on compiler ABI which is out of our scope for this article.
- The complete information on stack frame size, memory allocation, returning from stack frame is decided at compile time.
- Before diving into assembly code you should be aware of two things :
    1. CPU registers of x86 machine.
    2. x86 assembly instructions: As this is a very vast topic & updating quite frequently, we will only see the instructions needed for our examples.

## x86 CPU Registers

### General Purpose Registers:

| 32-bit SFR | 64-bit SFR | Name |
|------------|------------|------|
| eax | rax | Accumulator uses for arithmetic |
| ebx | rbx | Base uses for memory address calculations |
| ecx | rcx | Counter uses to hold loop count |
| edx | rdx | Double-word Accumulator or data register use for I/O port access |

### Pointer Register:

| 32-bit SFR | 64-bit SFR | Name |
|------------|------------|------|
| esp | rsp | Stack pointer |
| ebp | rbp | Frame/base pointer points current stack frame |
| eip | rip | Instruction pointer points to the next instruction to execute |

### Segment Register:

| SFR | Name |
|-----|------|
| cs | Code segment |
| ds | Data segment |
| ss | Stack segment |
| es | Extra segment |

### Index Registers:

| 32-bit SFR | 64-bit SFR | Name |
|------------|------------|------|
| esi | rsi | Source Index uses to point index in sequential memory operations |
| edi | rdi | Destination Index uses to point index in sequential memory operations |

Apart from all these, there are many other registers as well which even I don't know about. But above-mentioned registers are sufficient to understand the subsequent topics.

## How C Program Converts Into Assembly?

We will consider the following example with its disassembly inlined to understand its different aspect of working at machine level :

![How C program converted into assembly?](/images/How-C-program-converted-into-assembly-1024x441.png)

We will focus on a stack frame of the function `func()` But before analysing stack frame of it, we will see how the calling of function happens:

### Function calling

Function calling is done by `call` instruction(see Line 15) which is subroutine instruction equivalent to :

```asm
push rip + 1 ; return address is address of next instructions
jmp func
```

Here, `call` store the `rip+1`(not that +1 is just for simplicity, technically this will be substituted by the size of instruction) in the stack which is return address once call to `func()`ends.

### Function Stack Frame

A function stack frame is divided into three parts

1. [Prologue](https://en.wikipedia.org/wiki/Function_prologue)/Entry
2. User code
3. [Epilogue](https://en.wikipedia.org/wiki/Function_prologue#Epilogue)/Exit

**1\. Prologue/Entry:** As you can see instructions(line 2 to 4) generated against start bracket `{` is prologue which is setting up the stack frame for `func(), Line 2 is pushing the previous frame pointer into the stack & Line 3 is updating the current frame pointer with stack end which is going to be a new frame start.

`push` is basically equivalent to :

```asm
sub esp, 4   ; decrements ESP by 4 which is kind of space allocation
mov [esp], X ; put new stack item value X in
```

### Parameter Passing

Argument of `func()` is stored in `edi` register on Line 14 before calling `call` instruction. If there is more argument then it will be stored in a subsequent register or stack & address will be used. Line 4 in `func()`is reserving space by pulling frame pointer(pointed by `rbp` register) down by 4 bytes for the parameter `arg` as it is of type `int`. Then `mov` instruction will initialize it with value store in`edi`. This is how parameters are passed & stored in the current stack frame.

```
          ---|-------------------------|--- main()
             |                         |          
             |                         |          
             |                         |          
             |-------------------------|          
             |    main frame pointer   |          
rbp & rsp ---|-------------------------|--- func()
in func()    |           arg           |          
             |-------------------------|          
             |            a            |          
             |-------------------------|    stack 
             |            +            |      |   
             |            +            |      |   
             |            +            |      |   
          ---|-------------------------|--- \|/  
             |                         |          
             |                         |          
                                                   
```

### Allocating Space for Local Variables

**2\.** **User** **code:** Line 5 is reserving space for a local variable `a`, again by pulling frame pointer further down by 4 bytes. `mov` instruction will initialize that memory with a value `5`.

### Accessing Global & Local Static Variables

- As you can see above, `g` is addressed directly with its absolute addressing because its address is fixed which lies in the data segment.
- This is not the case all the time. Here we have compiled our code for  x86 mode, that's why it is accessing it with an absolute address.
- In the case of x64 mode, the address is resolved using `rip` register which meant that the assembler and linker should cooperate to compute the offset of `g` from the ultimate location of the current instruction which is pointed by `rip` register.
- The same statement stands true for the local static variables also.

**3\. Epilogue/Exit:** After the user code execution, the previous frame pointer is retrieved from the stack by `pop` instruction which we have stored in Line 2. `pop` is equivalent to:

```asm
mov X, [esp] ; put top stack item value into X 
add esp, 4   ; increments ESP by 4 which is kind of deallocation
```

### **Return From Function**

`ret` instruction jumps back to the next instruction from where `func()`called by retrieving the jump address from stack stored by `call` instruction. `ret` is subroutine instruction which is equivalent to:

```asm
pop rip ; 
jmp rip ;
```

If any return value specified then it will be stored in `eax` register which you can see in Line 16.

So, this is it for "How C program converts into assembly?". Although this kind of information is strictly coupled with compiler & ABI. But most of the compilers, ABI & instruction set architecture follows the same more or less. In case, you have not gone through [my previous articles](/posts/category/c-language/), here are simple FAQs helps you to understand better:

## FAQs

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

**A.** `alloca()`is the answer. Google about it or see [this](http://man7.org/linux/man-pages/man3/alloca.3.html). Although this is not recommended.
