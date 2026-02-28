FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=dragon
ENV USER=root
ENV HOME=/root
ENV SHELL=/bin/bash

RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server novnc websockify \
    ca-certificates curl wget git sudo docker.io htop btop neovim lsof \
    qemu-system cloud-image-utils xterm fluxbox dbus-x11 x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

RUN echo "dragon" > /etc/hostname && \
    echo "export PS1='root@dragon:\w\# '" >> /root/.bashrc && \
    echo "root:root" | chpasswd && \
    mkdir -p /root/.vnc && \
    echo "password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

WORKDIR /workspace

EXPOSE 6080 7860 22

CMD bash -c "\
    echo '127.0.0.1 dragon' >> /etc/hosts && \
    hostname dragon 2>/dev/null || true && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
    DISPLAY=:1 fluxbox & \
    DISPLAY=:1 xterm -geometry 1280x720 -fullscreen -sb -T 'Dragon VPS Terminal' -e /bin/bash & \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901"
