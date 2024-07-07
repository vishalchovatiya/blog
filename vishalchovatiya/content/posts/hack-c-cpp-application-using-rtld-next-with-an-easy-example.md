---
title: "How to hack C/C++ application using RTLD_NEXT with an easy example"
date: "2016-09-25"
categories: 
  - "linux-system-programming"
tags: 
  - "dlerror"
  - "dlsym"
  - "hack-c-c-application-using-rtld_next"
  - "ld_preload"
  - "rtld_next"
  - "shared-library-loading-sequence"
  - "strip"
  - "stripped-binaries"
---

While I was working as a core C library developer with my previous employer. I came across this RTLD\_NEXT flag in dynamic linking which has the amazing capability and can be easily exploited or used for unethical purpose(Here I intend to educate the developer to don't be victims). In this article, I will show you a simple way to hack C/C++ application using RTLD\_NEXT with an easy example.

## Brief

- Let say you have a C/C++ application/tool which is highly proprietary and driving most of the business to your company. You have done some licensing or encryption which prevents a hacker(or maybe rivals) from cracking your binary or to use it without your license keys or something.
- This binary can easily be cracked by the use of `RTLD_NEXT` flag if you have not taken enough precautions which we will discuss later in this article.

## Library linking & symbol resolution

- Library linking & symbol resolution i.e. extracting address(precisely offset here in dynamic linking case) of function is specified at compile time.
- For example, there are four shared libraries linked & loaded dynamically in order as `A.so`, `B.so`, `C.so` & `D.so` with the main application. And `funcXYZ()`is called from the main application which is defined in both the library `C.so` & `D.so` with the same prototype.
- Then `funcXYZ()`from `C.so` will be called first as it's ahead of `D.so` in linking order.

## Intro to RTLD\_NEXT

But what if you want to call `funcXYZ() from `D.so` ? You can achieve this by `RTLD_NEXT` flag defined in `<dlfcn.h>`. What you have to do is define your `funcXYZ()`as below in `C.so`:

```c
void funcXYZ()
{
    void (*fptr)(void) = NULL;

    if ((fptr = (void (*)(void))dlsym(RTLD_NEXT, "funcXYZ")) == NULL)
    {
        (void)printf("dlsym: %s\n", dlerror());
        exit(1);
    }

    return ((*fptr)());
}
```

- Now, whenever `funcXYZ()`called from main application it will come to `C.so` which simply search for the same symbol from next loaded libraries i.e. `D.so` .
- [dlsym()](https://linux.die.net/man/3/dlsym) search for symbol provided in argument from the [memory](/posts/how-does-virtual-memory-work/) and a returns function pointer to the same.

## Let's hack C/C++ application using RTLD\_NEXT

#### malloc.c

```c
#include <stdio.h>
#include <dlfcn.h>

void *malloc(size_t size)
{
    static void *(*fptr)(size_t) = NULL;

    /* look up of malloc, only the first time we are here */
    if (fptr == NULL)
    {
        fptr = (void *(*)(size_t))dlsym(RTLD_NEXT, "malloc");
        if (fptr == NULL)
        {
            printf("dlsym: %s\n", dlerror());
            return NULL;
        }
    }

    printf("Our Malloc\n");

    return (*fptr)(size); // Calling original malloc
}
```

#### main.c

```c
#include <stdio.h>
#include <stdlib.h>

int main()
{

    malloc(1);

    return 0;
}
```

#### Creating a shared library

```bash
$ gcc -o malloc.so -shared -fPIC malloc.c -D_GNU_SOURCE
```

#### Linking & executing the main application

```bash
$ gcc -o main main.c ./malloc.so -ldl
$ ./main
Our Malloc
```

**Note:** You can also use `LD_PRELOAD` as below, which loads the specified library first. No need to mention `./malloc.so` explicitly in the compilation.

```bash
$ LD_PRELOAD=`pwd`/malloc.so ./main
```

## How it works

- When you compile `main.c` with `gcc -o main main.c ./malloc.so -ldl`, you specify `malloc.so` explicitly on first order. We can verify this by `ldd` command

```bash
$ ldd main
linux-vdso.so.1 => (0x00007fff37bf4000)
malloc.so (0x00007fc5df598000)
libdl.so.2 => /lib64/libdl.so.2 (0x00007fc5df37d000)
libc.so.6 => /lib64/libc.so.6 (0x00007fc5defbb000)
/lib64/ld-linux-x86-64.so.2 (0x00007fc5df79b000)
```

- So when you call [malloc](/posts/how-do-malloc-free-work-in-c/) it will refer the first occurrence of the symbol from the loaded library sequence which is in our `malloc.so` library.
- We now extract original malloc from next loaded shared library which is `/lib64/libc.so.6`.

## What RTLD\_NEXT used for?

An obvious question would be "Why the hell library designer/developer keep this kind of vulnerability?"

- `RTLD_NEXT` allows one to provide a wrapper around a function defined in another shared library. At least that is what [man page of dlsym](https://linux.die.net/man/3/dlsym) describes.

I am still confused! Is this feature or vulnerability?

## Vulnerability

- If you not experienced enough then perhaps your question would be "What's vulnerability in this ?"?‍♀️ then let me tell you, my friend, you might have stored license string, encryption key or any other proprietary data to validate against user access which usually programmer stores using struct or array kind of data structures.
- Now, we generally use `memcmp() or `strcmp()`library functions to compare user access or validate key/data. You can easily generate wrapper around these functions using `RTLD_NEXT` and manipulate it.
- Some companies use real-time authentication by an HTTP request which can also be cracked as there might be a particular function returning `true` or `false` as access check. You can simply create a wrapper of that function to manipulate it.
- This may take more time to find out function by hit & trial method. But it's not impossible. To figure out function name you can use `nm` or `readelf` like utilities which list out symbol names & it's corresponding addresses/offset as follows

```bash
$ nm main 
....                                                                                                                                                             
0000000000600e00 d _DYNAMIC                                                                                                                                           
00000000004005b7 T main                                                                                                                                                      
                 U malloc                                                                                                                                                    
0000000000400540 t register_tm_clones    
....
```

- If you want to learn more about binary file format ELF, then I have written a separate article for it [here](/posts/understand-elf-file-format/).

## Precautions you should consider

#### Use stripped binaries for release

Compiled binary usually contain symbol information as we show using `nm` utility above. But when you strip binary it just strip [symbol table](/posts/understand-elf-file-format/) from it which is not necessary for execution as it is only being used in debugging & link resolution at compile time. Stripped binary can produced with the help of the compiler itself, e.g. GNU GCC compilers' `-s` flag, or with a dedicated tool like strip on Unix.

```bash
$ strip --strip-all main
$ nm main                                                                                                                                                              
nm: main: no symbols
$
```

#### Static linking

Rather than releasing a dynamic linking binary, compile static version & strip it. Although it has some cons which are out of topic for this article.

#### Do not use library functions for handling proprietary data

While processing proprietary data in your application do not rely on library functions rather design your own with weird names. If you are storing read-only proprietary data in ASCII format within binary then encrypt it or simply add a particular number in every char so that memory dump won't show any human-readable sentences or words.
