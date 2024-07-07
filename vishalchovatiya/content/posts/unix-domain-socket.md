---
title: "Unix Domain Socket"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "ipc"
  - "unix-domain-socket"
  - "why-we-need-unix-domain-socket"
---

### Brief

- A Unix domain socket or IPC socket is a data communications endpoint for exchanging data between processes executing on the same host operating system.
- The API for Unix domain sockets is similar to that of an Internet socket, but rather than using an underlying network protocol, all communication occurs entirely within the operating system kernel.
- Unix domain sockets use the file system as their address namespace. Processes reference Unix domain sockets as file system inodes, so two processes can communicate by opening the same socket.

### Why we need Unix domain socket?

- In addition to sending data, processes may send file descriptors across a Unix domain socket connection using the `sendmsg() and `recvmsg()`system calls.
- This allows the sending processes to grant the receiving process access to a file descriptor for which the receiving process otherwise does not have access.
- This can be used to implement a limited form of capability-based security.
- For example, this allows the AntiVirus scanner to run as an unprivileged daemon on Linux, yet still read any file sent to the daemon's Unix domain socket.

### Server

```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

static void displayError(const char *);

const char socketPath[]  = "/tmp/my_sock";  /* Socket With Absolute Pathname */

int main(int argc, char **argv, char **envp) {
    int sockfd;                 /* Socket File Descriptor */
    int connfd;                 /* Connection Fide Descriptor On Whch We Communicate */
    struct sockaddr_un socketAddr;      /* AF_UNIX */

    /* Create a AF_UNIX (aka AF_LOCAL) socket */
    if ( (sockfd = socket(AF_UNIX,SOCK_STREAM,0)) < 0 )
        displayError("socket");

    /* Here we remove name of socket from file system, in case it existed from a prior run.*/
    unlink(socketPath);

    memset( &socketAddr, 0, sizeof socketAddr);
    socketAddr.sun_family = AF_UNIX;
    strncpy( socketAddr.sun_path, socketPath,  sizeof socketAddr.sun_path-1);

    if ( bind(sockfd, (struct sockaddr *)&socketAddr, sizeof(struct sockaddr)) < 0 )
        displayError("Could not bind");

    if( ( listen( sockfd, 10)  ) < 0 )
        displayError("Could not listen");

    if( ( connfd = accept( sockfd, (struct sockaddr*)NULL, NULL) ) < 0 )
        displayError("Could not accept");

    write(connfd, "Server Message\n", strlen("Server Message\n"));

    /* Close & unlink our socket path */
    close(sockfd) ;
    unlink(socketPath);

    return 0;
}

/* This function reports the error and exits back to the shell: */
static void displayError(const char *on_what) {
    perror(on_what);
    exit(1);
}

```

### Client

```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

static void displayError(const char *on_what);

const char socketPath[]  = "/tmp/my_sock";  

int main(int argc, char **argv, char **envp) {
    int n = 0;
    char recvBuff[1024];
    int sockfd;                 
    struct sockaddr_un socketAddr;          

    /* Create a AF_UNIX (aka AF_LOCAL) socket: */
    if ( (sockfd = socket(AF_UNIX,SOCK_STREAM,0)) < 0 )
        displayError("socket");

    memset( &socketAddr, 0, sizeof socketAddr);
    socketAddr.sun_family = AF_UNIX;
    strncpy( socketAddr.sun_path, socketPath,  sizeof socketAddr.sun_path-1);

    if( connect(sockfd, (struct sockaddr *)&socketAddr, sizeof(socketAddr)) < 0)
        displayError("Connect Failed");

    while ( (n = read(sockfd, recvBuff, sizeof(recvBuff)-1)) > 0)
    {
        recvBuff[n] = 0;
        if(fputs(recvBuff, stdout) == EOF)
            displayError("fputs error");
    }

    if(n < 0)
        displayError("Read error");

    /* Close and unlink our socket path: */
    close(sockfd) ;
    unlink(socketPath);

    return 0;
 }


/* This function reports the error and exits back to the shell: */
static void displayError(const char *on_what) {
    perror(on_what);
    exit(1);
}
```
