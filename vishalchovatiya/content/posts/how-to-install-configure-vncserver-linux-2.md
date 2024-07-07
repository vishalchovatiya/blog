---
title: "How to Install and Configure VNC Server on Linux!"
date: "2019-09-15"
categories: 
  - "developer-useful"
  - "misc"
tags: 
  - "grey-screen-error"
  - "install-and-configure-vncserver"
  - "linux"
  - "vnc"
  - "vnc-server"
  - "vncserver"
---

In the early days of my career, I used to work on Linux machines remotely. In those days, I was not knowing about SSH & all and people around me was using Putty as it was very easy & simple. Open source as well. You just have to enter IP & Port and you would get command-line access to remote machine. here, we will discuss "how to install and configure VNC server on Linux?"

As development/deployment of build complexity increase over the year & I have gained some experience, my necessity increased. Then, I have to work on 2-3 different machine simultaneously and sometimes have to execute command synchronously in different machine.

Then I came across [MobaXterm](https://mobaxterm.mobatek.net/), which gives you screen split & command recording as macros made me astonish. It also support Window forwarding so you can also use GUI(not properly). This tool helped me a lot along the way of my professional journey.

Recently I have used `vncserver` & felt, earlier whatever I was using is scrap you can access complete full-fledged remote system with minimal processing cost.

Then I installed `TigerVNC Viewer` in my laptop which has windows 10 & `vncserver` in remote machine which has Ubuntu 17.

## How to install and configure VNC server on Linux?

### **Installing** `**vncserver**`

```bash
sudo apt-get update
sudo apt-get install xfce4 xfce4-goodies tightvncserver
```

### **Configure**

- Set password

```bash
$ vncpasswd
```

you prompted with entry password & confirm password lines where you have to set password.

- Running VNC Server

```bash
$ vncserver
New 'X' desktop is vishal-:1

Creating default startup script /home/vishal/.vnc/xstartup
Starting applications specified in /home/vishal/.vnc/xstartup
Log file is /home/vishal/.vnc/vishal-:1.log
```

- Now open TigerVNC Viewer(which may be on desktop or search using `Windows Key`). Enter: Like this & click on connect.

You will prompted by password screen. You have to enter the password you set when running command `vncpasswd`.

## **Debugging Error**

I have got `grey screen` nothing else. I have resolved that error following ways.

#### **VNC server grey screen problem solution**

- Kill running server, there are two ways to do that  
    1). `vncserver -list` gives you a list of running `vncserver`.  
    2). `ps -ef | grep vnc` will give you a list of running vnc servers & their display number.

```bash
$ vncserver -kill :1
```

I have given `:1` as my display no is 1

- Open `xstartup` file

```bash
$ vim ~/.vnc/xstartup
```

Add following lines

```bash
#!/bin/sh

def
export XKLXMODMAPDISABLE=1
unset SESSIONMANAGER
unset DBUSSESSIONBUSADDRESS

gnome-panel &
gnome-settings-daemon &
metacity &
nautilus &
gnome-terminal &
```

Save & close it. Then run

```bash
$ sudo apt-get install ubuntu-gnome-desktop -y
```

Will take some time. Restart/configure `vncserver` by. Your problem should be resolved.

## **VNC server related utilities**

- Copy-paste between host & TigerVNC viewer

```bash
$ vncconfig --nowin &
```
