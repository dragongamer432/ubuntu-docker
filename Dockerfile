FROM --platform=linux/amd64 ubuntu:22.04

# Core environment setup
ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_PASSWORD=root
ENV HOSTNAME=dragon

# Install Desktop, VNC, SSH, and basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common ca-certificates gnupg2 \
    openssh-server xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

# Fix Firefox Installation (Direct key download to prevent GPG errors)
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO- "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x738BEB9321D1AAEC13EA9391AEBDF4819BE21867" | gpg --dearmor -o /etc/apt/keyrings/mozillateam.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/mozillateam.gpg] http://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/mozillateam-ppa.list && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && apt-get install -y firefox

# Set root:root credentials and enable root SSH access
RUN echo "root:$ROOT_PASSWORD" | chpasswd && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    touch /root/.Xauthority

EXPOSE 22 5901 6080

# Start script: Sets hostname, SSH, VNC, and NoVNC
CMD bash -c "\
    echo 'dragon' > /etc/hostname && \
    hostname dragon 2>/dev/null || true && \
    /usr/sbin/sshd && \
    vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE :1 && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    tail -f /dev/null"
