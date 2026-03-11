FROM ubuntu:22.04

# ---- Configuration & Branding ----
ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=dragoncloud-vps
ENV PASSWORD=dragon

# ---- 1. Install System Core & Tools ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo openssh-server ca-certificates curl wget git \
    iproute2 net-tools htop neovim screen tmate \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install code-server and Flask (for the web button)
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    pip3 install flask

# ---- 2. Setup Access ----
RUN mkdir -p /var/run/sshd && \
    echo "root:$PASSWORD" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# ---- 3. Create the DragonCloud Control Panel (app.py) ----
# This Python script provides the button to generate tmate keys
RUN echo 'from flask import Flask, render_template_string\n\
import subprocess, time\n\
app = Flask(__name__)\n\
@app.route("/")\n\
def home():\n\
    return """\n\
    <body style=\"background:#0f172a; color:white; font-family:sans-serif; text-align:center; padding-top:100px;\">\n\
        <h1 style=\"color:#38bdf8;\">DragonCloud VPS Panel</h1>\n\
        <p>Access your VPS via Browser or Terminal</p>\n\
        <a href=\"/code\" target=\"_blank\" style=\"display:inline-block; margin:10px; padding:15px 30px; background:#1e293b; color:#38bdf8; border:1px solid #38bdf8; text-decoration:none; border-radius:5px;\">Open VS Code Browser</a>\n\
        <form action=\"/generate\" method=\"post\" style=\"margin-top:20px;\">\n\
            <button type=\"submit\" style=\"padding:15px 30px; background:#38bdf8; color:#0f172a; border:none; border-radius:5px; font-weight:bold; cursor:pointer;\">Generate One-Time SSH Key</button>\n\
        </form>\n\
    </body>"""\n\
@app.route("/generate", methods=["POST"])\n\
def generate():\n\
    subprocess.Popen(["tmate", "-S", "/tmp/tmate.sock", "new-session", "-d"])\n\
    subprocess.run(["tmate", "-S", "/tmp/tmate.sock", "wait-for", "tmate-ready"])\n\
    res = subprocess.check_output(["tmate", "-S", "/tmp/tmate.sock", "display", "-p", "#{tmate_ssh}"]).decode("utf-8")\n\
    return f\"<body style=\'background:#0f172a; color:white; font-family:monospace; padding:50px;\'><h1>DragonCloud SSH Key</h1><p style=\'background:#1e293b; padding:20px; border-left:5px solid #38bdf8;\'>{res}</p><br><a href=\'/\' style=\'color:#38bdf8;\'>Back to Panel</a></body>\"\n\
if __name__ == \"__main__\":\n\
    app.run(host=\"0.0.0.0\", port=8080)' > /app.py

# ---- 4. Entrypoint Script ----
RUN echo '#!/bin/bash\n\
service ssh start\n\
# Start code-server in background on port 8443\n\
code-server --bind-addr 0.0.0.0:8443 --auth password &\n\
# Start the DragonCloud Web Panel on port 8080 (Railway default)\n\
python3 /app.py' > /entrypoint.sh && chmod +x /entrypoint.sh

# ---- 5. Final Setup ----
WORKDIR /home/dragoncloud
EXPOSE 8080 8443 22
ENTRYPOINT ["/entrypoint.sh"]
