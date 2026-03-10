FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=dragon

# ---- Base packages ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    docker.io \
    htop \
    btop \
    mysql-server \
    neovim \
    lsof \
    qemu-system-x86 \
    cloud-image-utils \
    && rm -rf /var/lib/apt/lists/*

# ---- Install code-server ----
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ---- Workspace ----
WORKDIR /workspace

EXPOSE 7860

CMD ["code-server", "--bind-addr", "0.0.0.0:7860", "--auth", "none"]
