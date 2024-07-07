# Use a more comprehensive base image
FROM ubuntu:22.04

LABEL description="C/C++ blogging environment" 

# Install essential packages and tools
RUN apt-get update 
RUN apt-get install -y \
        build-essential \
        make \
        cmake \
        gdb \
        gdbserver \
        curl \
        wget \
        git \
        nodejs \
        npm \
        rsync \
        zip \
        openssh-server \
        git \
        libgmp3-dev \
        ninja-build \
        clang-format \
        && rm -rf /var/lib/apt/lists/*

# Install Hugo
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.128.0/hugo_extended_0.128.0_linux-amd64.deb \
    && dpkg -i hugo_extended_0.128.0_linux-amd64.deb \
    && rm hugo_extended_0.128.0_linux-amd64.deb

# Configure SSH for communication with Visual Studio Code
RUN mkdir -p /var/run/sshd

# PermitRootLogin without-password through client & generate user keys
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    ssh-keygen -A


# Create directory CP & go there
RUN mkdir -p /blog
WORKDIR /blog

# Run ssh server & expose port port 22 to connect from host PC
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# Setup git
RUN git config --global user.name "Vishal Chovatiya"
RUN git config --global user.email "vishalchovatiya@ymail.com"
