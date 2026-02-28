FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV USER=root
ENV SHELL=/bin/bash

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata gnupg openssh-server \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update -y && apt install -y firefox xubuntu-icon-theme

RUN mkdir -p /var/run/sshd && \
    echo "root:root" | chpasswd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    touch /root/.Xauthority

EXPOSE 22 5901 6080

CMD bash -c "\
    echo 'dragon' > /etc/hostname && \
    hostname dragon 2>/dev/null || true && \
    echo '127.0.0.1 dragon' >> /etc/hosts && \
    /usr/sbin/sshd && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE :1 && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    echo '--------------------------------------------------' && \
    echo 'VPS ONLINE! Host: dragon | User: root | Pass: root' && \
    echo '--------------------------------------------------' && \
    tail -f /dev/null"
