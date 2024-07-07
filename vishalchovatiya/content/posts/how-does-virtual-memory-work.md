---
title: "How Does Virtual Memory Work?"
date: "2016-10-15"
categories: 
  - "misc"
  - "operating-system"
tags: 
  - "combining-page"
  - "how-does-vmm-work"
  - "how-virtual-memory-work"
  - "page-fault"
  - "paging"
  - "paging-page-fault-terms"
  - "thrashing"
  - "virtual-memory"
  - "virtual-memory-can-slow-down-performancethrashing"
  - "vmm"
  - "why-virtual-memory-used"
featuredImage: "/images/How-Does-Virtual-Memory-Work-vishalchovatiya.png"
---

Have you ever wondered , How game of size 8 GB is running on a computer has 4 GB of RAM only? or You can play multiple movies simultaneously combined size more than RAM size? If you are a software developer, you may come across a word like multi-tasking or multiprocessing which is key concept behind this. In other words, it creates virtual memory which is a memory management technique. Here we will see how it works

## How Does Virtual Memory Work?

![](/images/How-Does-Virtual-Memory-Work.jpg)

- Let’s say that an OS needs 120 MB of memory in order to hold all the running programs.
- But there’s currently only 50 MB of available physical memory stored on the RAM chips.
- The OS will then set up 120 MB of virtual memory & will use a program called the virtual memory manager(VMM) to manage that 120 MB.
- The VMM will create a file on the hard disk that is 70 MB (120 – 50) in size to account for the extra memory that’s needed.
- The OS will now proceed to address memory as if there were actually 120 MB of real memory stored in the RAM, even though there’s really only 50 MB.
- It is the responsibility of the VMM to deal with the fact that there is only 50 MB of real memory.

**/!\\:** If you want to know in-depth of virtual memory implementation, you are at the wrong place. This article will only clear your concept of "How does virtual memory work"!

## Jargons

| Term | Definition |
|------|------------|
| Physical Memory or Main Memory | RAM |
| Secondary Memory | HDD or SSD |
| Virtual Memory | Illusion created by OS for optimization (You can say this definition too) |
| VMM | Virtual Memory Manager |
| Process Address Space | Set of logical addresses that a process references in its code (provided by VMM) |
| OS | Operating system (I think this is not needed) |
| AKA | Also known as |

## How Does VMM Work?

- VMM creates a file on the hard disk that holds the extra memory which needed by the OS, which in our case is 70 MB in size.
- This file called a paging file (AKA swap-file/page-frames) & plays an important role in virtual memory(i.e. How does virtual memory work).
- The paging file combined with the RAM accounts for all of the memory.
- Whenever the OS needs a ‘block’ of memory that’s not in the main(RAM) memory, the VMM takes a block from the real memory that hasn’t used recently, writes it to the paging file & then reads the block of memory that the OS needs from the paging file.
- The VMM then takes the block of memory from the paging file(which needed currently) & moves it into the main memory – in place of the old block.
- This process is called swapping (also known as paging) & the blocks of memory that are swapped, called pages. There are several algorithms for this process, called [Page Replacement Algorithms](https://en.wikipedia.org/wiki/Page_replacement_algorithm).
- The group of pages that currently exist in RAM & that is dedicated to a specific process, is known as the working set for that process.

## Why Virtual Memory Used?

- There are two reasons why one would want this:
    1. To allow the use of programs that are too big to physically fit in memory.
    2. The other reason is to allow for multitasking.
- Before virtual memory existed, a word processor, e-mail program, & browser couldn’t be run at the same time unless there was enough memory to hold all three programs at once.
- This would mean that one would have to close one program in order to run the other, but now with virtual memory, multitasking is possible even when there is not enough memory to hold all [executing programs](/posts/program-gets-run-linux/) at once.

## Which OS Implemented Virtual Memory?

- Some of the most popular OSs like Windows, Mac OSX, & Linux implemented VMM.

## Virtual Memory Can Slow Down Performance(Thrashing)!

- If the size of virtual memory is quite large in comparison to the main memory, then more swapping to & from the hard disk will occur as a result.
- Accessing the hard disk is far slower than using the main memory(RAM).
- Using too many programs at once in a system with an insufficient amount of RAM results in constant disk swapping – also called thrashing, which can really slow down a system’s performance.

## Terms Associated With Virtual Memory

#### **Page**

- In the Paging Scheme, the OS retrieves data from Hard Disk in same-size blocks called pages.

#### **Paging**

- It is a VMM scheme by which computer stores & retrieves data from secondary storage(Hard Disk--Nowadays SSD) for use in real memory(RAM).
- Paging let programs exceed the size of available physical memory & form virtual memory.

#### **Page Fault**

- A page fault occurs when a program tries to access a page that is mapped in address space but not loaded in the physical memory(RAM).
- Which means that the program would have to access the paging file (which resides on the hard disk) to retrieve the desired page.

### [](https://github.com/VisheshPatel/OS-Concepts/blob/master/Paging%20%26%20Page%20Faults.md#combining-page-paging--page-fault-terms)Combining Page, Paging & Page Fault Terms

- When OS create virtual memory it will use paging scheme through which some block of memory is loaded in RAM & rest is stored as a paging file in HDD(SSD in some cases)
- When our [program(application) look for something which is not in RAM](/posts/how-c-program-stored-in-ram-memory/) but stored as paging file, page fault occur.
- There are many sophisticated algorithms to decrease page fault rate, like LRU, MFU, FIFO, NRU, etc
