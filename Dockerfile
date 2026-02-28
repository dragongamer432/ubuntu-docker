FROM ubuntu:22.04

# Core environment setup
ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_PASSWORD=root
ENV HOSTNAME=dragon

# Install VPS Essentials, Desktop, and SSH
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo xfce4 xfce4-goodies \
    tigervnc-standalone-server novnc websockify \
    curl wget git python3 net-tools iputils-ping dbus-x11 \
    software-properties-common ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 1. Set Root Credentials (User: root | Pass: root)
# 2. Enable SSH Root Login and Password Auth
# 3. Prepare SSH directory
RUN echo "root:$ROOT_PASSWORD" | chpasswd && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install Firefox (Stable PPA version)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && apt-get install -y firefox

# Expose SSH (22) and NoVNC (6080)
EXPOSE 22 6080

# Startup script: Sets Hostname, starts SSH, and starts VNC/NoVNC
CMD bash -c "\
    echo 'dragon' > /etc/hostname && \
    hostname dragon && \
    /usr/sbin/sshd && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
    openssl req -new -subj '/C=US' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    echo '------------------------------------------' && \
    echo 'VPS STATUS: ONLINE' && \
    echo 'HOSTNAME: dragon' && \
    echo 'USER: root | PASS: root' && \
    echo '------------------------------------------' && \
    tail -f /dev/null"