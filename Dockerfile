FROM ubuntu:22.04

# ---- Configuration & Branding ----
ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=dragoncloud-vps
ENV PASSWORD=dragon

# ---- 1. Install System Core & Tools ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    openssh-server \
    ca-certificates \
    curl \
    wget \
    git \
    iproute2 \
    net-tools \
    htop \
    neovim \
    screen \
    python3 \
    python3-pip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install code-server (Official Binary)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ---- 2. Setup Access & SSH ----
RUN mkdir -p /var/run/sshd && \
    echo "root:$PASSWORD" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ---- 3. Entrypoint Script ----
# This script starts the SSH service and the code-server
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "----------------------------------------------------"\n\
echo "   DragonCloud VPS is ONLINE (Railway Edition)      "\n\
echo "   Access via Browser on Port: 8080                 "\n\
echo "----------------------------------------------------"\n\
# Start code-server on port 8080 (Railway default public port)\n\
exec code-server --bind-addr 0.0.0.0:8080 --auth password' > /entrypoint.sh && chmod +x /entrypoint.sh

# ---- 4. Final Setup ----
WORKDIR /home/dragoncloud

# Railway routes traffic to port 8080 by default
EXPOSE 8080 22

ENTRYPOINT ["/entrypoint.sh"]
