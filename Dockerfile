FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV USER=root
ENV XDG_RUNTIME_DIR=/tmp/runtime-root

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm init systemd snapd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common ca-certificates gnupg openssh-server \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update -y && apt install -y firefox xubuntu-icon-theme

RUN echo "root:root" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    touch /root/.Xauthority && \
    mkdir -p /tmp/runtime-root && chmod 0700 /tmp/runtime-root

EXPOSE 5901 6080

CMD bash -c "\
    echo 'dragon' > /etc/hostname && \
    hostname dragon 2>/dev/null || true && \
    echo 'root:root' | chpasswd && \
    /usr/sbin/sshd && \
    vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE :1 && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    echo '-----------------------------------' && \
    echo 'VPS READY: root@dragon' && \
    echo '-----------------------------------' && \
    tail -f /dev/null"
