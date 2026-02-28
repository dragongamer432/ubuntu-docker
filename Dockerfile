FROM ubuntu:22.04

# Identity & Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV USER=root

# 1. Install strictly what's needed for Terminal + noVNC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server novnc websockify \
    ca-certificates curl wget git sudo docker.io htop btop neovim lsof \
    qemu-system cloud-image-utils xterm dbus-x11 x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# 2. Fix Terminal Identity
RUN echo "export PS1='root@dragon:\w\# '" >> /root/.bashrc && \
    mkdir -p /root/.vnc && \
    touch /root/.Xauthority

# 3. Create a startup script that forces the terminal to stay open
RUN echo "#!/bin/bash\n\
hostname dragon 2>/dev/null || true\n\
xterm -geometry 150x50+0+0 -name 'DragonTerminal' -e /bin/bash" > /root/start_term.sh && \
    chmod +x /root/start_term.sh

EXPOSE 6080

# 4. The Startup: Starts VNC, and importantly, maps it to NoVNC
CMD bash -c "\
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
    DISPLAY=:1 /root/start_term.sh & \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901"
