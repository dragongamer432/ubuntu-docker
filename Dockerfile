FROM ubuntu:22.04

# 1. Identity & Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=dragoncloud-railway

# 2. Install Essentials
# Note: We omit 'systemd' as it requires privileged mode to boot correctly
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    openssh-server \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg2 \
    iproute2 \
    net-tools \
    htop \
    neovim \
    screen \
    zip \
    unzip \
    mariadb-client \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# 3. Secure SSH Setup
# Default password: dragon (Change this via Railway Environment Variables if possible)
RUN mkdir -p /var/run/sshd && \
    echo 'root:dragon' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 4. Install Cloudflared (Works perfectly on Railway)
RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared.deb && rm cloudflared.deb

# 5. DragonCloud Entrypoint Script
# Since we can't use systemd, this script manually starts your services
RUN echo '#!/bin/bash\n\
service ssh start\n\
service nginx start\n\
echo "----------------------------------------------------"\n\
echo "   DragonCloud Railway VPS is now ONLINE             "\n\
echo "   SSH Port: 22 | Web Port: 80                       "\n\
echo "----------------------------------------------------"\n\
# Keep the container running\n\
tail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /home/dragoncloud

# Railway typically uses port 8080 or the $PORT variable
EXPOSE 22 80 443 8080

ENTRYPOINT ["/entrypoint.sh"]
