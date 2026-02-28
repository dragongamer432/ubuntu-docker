FROM debian:trixie-slim

# Identity & Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV USER=root
ENV SHELL=/bin/bash
ENV TERM=xterm

# 1. Install Full VPS Suite (Desktop, SSH, Admin Tools)
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo vim net-tools curl wget git tzdata gnupg openssh-server \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    ca-certificates procps firefox-esr \
    && rm -rf /var/lib/apt/lists/*

# 2. Force Hostname & Shell Identity (The "Real VPS" Prompt)
RUN echo "dragon" > /etc/hostname && \
    echo "export PS1='root@dragon:\w\# '" >> /root/.bashrc && \
    echo "alias ll='ls -la'" >> /root/.bashrc

# 3. Secure Root Access & SSH Configuration
RUN mkdir -p /var/run/sshd && \
    echo "root:root" | chpasswd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    touch /root/.Xauthority

# Expose Web GUI (6080) and SSH (22)
EXPOSE 6080 22

# 4. Universal Startup: Forces dragon identity and starts background services
CMD bash -c "\
    echo '127.0.0.1 dragon' >> /etc/hosts && \
    hostname dragon 2>/dev/null || true && \
    /usr/sbin/sshd && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    echo '------------------------------------------------' && \
    echo 'DEBIAN 13 VPS ONLINE | USER: root | PASS: root' && \
    echo '------------------------------------------------' && \
    tail -f /dev/null"
