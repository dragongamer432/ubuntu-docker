FROM ubuntu:22.04

# 1. Identity & Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=dragoncloud-vps
ENV container docker
STOPSIGNAL SIGRTMIN+3

# 2. Essential "Bare-Metal" Layer
# We include kmod and iptables so Tailscale/Wings can modify the kernel's network stack.
RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd \
    systemd-sysv \
    sudo \
    openssh-server \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg2 \
    software-properties-common \
    iptables \
    kmod \
    iproute2 \
    net-tools \
    dbus \
    udev \
    htop \
    neovim \
    && rm -rf /var/lib/apt/lists/*

# 3. Secure Access Configuration
# Default password is 'dragon' - Change this after your first login!
RUN echo 'root:dragon' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir -p /run/sshd

# 4. Systemd Optimization for Docker
# This strips away the parts of systemd that try to talk to physical hardware.
RUN find /lib/systemd/system/sysinit.target.wants/ -link 1 -type f -not -name 'systemd-tmpfiles-setup.service' -delete; \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# 5. Persistent Storage & Networking
# Volumes for Pterodactyl data and Docker-in-Docker layers
VOLUME [ "/sys/fs/cgroup", "/var/lib/docker", "/etc/pterodactyl", "/var/lib/tailscale" ]

# Standard VPS Ports
EXPOSE 22 80 443 8080 25565 8443

# Boot the system as PID 1
CMD ["/lib/systemd/systemd"]
