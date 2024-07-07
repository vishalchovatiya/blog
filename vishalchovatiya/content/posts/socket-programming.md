---
title: "Socket Programming"
date: "2016-09-10"
categories: 
  - "linux-system-programming"
tags: 
  - "socket-programming"
---

### Points To Catch

- On a single system, Two processes can communicate through
    1. Pipes
    2. Message queues
    3. Shared memory
- To communicate between two processes over a network, you need Socket
- Socket = Endpoint of communication between two systems on a network OR Combination of IP & Port Number

### [](https://github.com/VisheshPatel/Linux-System-Programming/blob/master/Socket%20Programming.md#server-example)Server Example

```c
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>

void ErrorAndExit(const char *str);

#define IP       "127.0.0.1"    /* Local Host OR Should be your local IP for test */
#define PORT     5000

int main(int argc, char *argv[])
{
        int listenfd = 0, connfd = 0;
        struct sockaddr_in serv_addr = {0};

        if( (listenfd = socket(AF_INET, SOCK_STREAM, 0) ) < 0 )
                ErrorAndExit("Could not create socket");

        serv_addr.sin_family = AF_INET;
        serv_addr.sin_addr.s_addr = inet_addr(IP);
        serv_addr.sin_port = htons(PORT);

        if( (bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) ) < 0 )
                ErrorAndExit("Could not bind on Given IP");

        if( (listen(listenfd, 10)  ) < 0 )
                ErrorAndExit("Could not listen");

        if( ( connfd = accept(listenfd, (struct sockaddr*)NULL, NULL) ) < 0 )
                ErrorAndExit("Could not accept");

        write(connfd, "Server Message", strlen("Server Message"));

        close(connfd);

        return 0;
}

void ErrorAndExit(const char *str)
{
        printf("Error : %s\n", str);
        exit(EXIT_FAILURE);
}

```

- **socket()** creates socket inside the kernel & returns socket descriptor.
    1. AF\_INET represents IPv4 addresses.
    2. SOCK\_STREAM specifies communication semantics means how communications would carry out.
    3. The 3rd argument is zero to let the kernel decide the default protocol to use for this connection. The default protocol used is TCP.
- bind(), wait for client requests on particular IP-Port specified in the structure serv\_addr.
- listen() with the second argument as 10 specifies a maximum number of client connections that server will queue for this listening socket.
- accept(), but the server into sleep & when client requests, the three-way TCP handshake\* is complete, the function wakes up & returns the socket descriptor representing the client socket.
- As soon as the server gets a request from the client, it prepares its message & writes on the client socket through the descriptor returned by accept().

### [](https://github.com/VisheshPatel/Linux-System-Programming/blob/master/Socket%20Programming.md#client-example)Client Example

```c
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

void ErrorAndExit(const char *str);

#define IP       "127.0.0.1"    /* Local Host OR Should be your local IP for test */
#define PORT     5000

int main()
{
        int sockfd = 0, n = 0;
        char recvBuff[1024];
        struct sockaddr_in serv_addr = {0};

        memset(recvBuff, `0`,sizeof(recvBuff));

        if((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
                ErrorAndExit("Could not create socket");

        serv_addr.sin_family = AF_INET;
        serv_addr.sin_port = htons(PORT);
        serv_addr.sin_addr.s_addr = inet_addr(IP);

        if( connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
                ErrorAndExit("Connect Failed");

        while ( (n = read(sockfd, recvBuff, sizeof(recvBuff)-1)) > 0)
        {
                recvBuff[n] = 0;
                if(fputs(recvBuff, stdout) == EOF)
                        ErrorAndExit("fputs error");
        }

        if(n < 0)
                ErrorAndExit("Read error");

        return 0;
}

void ErrorAndExit(const char *str)
{
        printf("Error : %s\n", str);
        exit(EXIT_FAILURE);
}
```

- **socket()** does work the same as mentioned in server
- connect() will connect this socket with a remote host whose IP-Port & other info bundled up in a structure sockaddr\_in.
- Once the sockets are connected, the server sends the data on clients socket through clients socket descriptor and a client can read it through normal read call on its socket descriptor.
