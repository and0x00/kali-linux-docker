# Kali Linux with i3 🐉
FROM kalilinux/kali-rolling:latest

ARG PASSWORD
ENV SSH_PORT 22
ENV XVNC_PORT 5901

ENV DEBIAN_FRONTEND noninteractive

# Update and install basic packages

RUN apt update -q --fix-missing
RUN apt upgrade -y
RUN apt -y install --no-install-recommends \
    sudo wget curl \
    dbus-x11 xinit kali-desktop-i3-gaps i3status \
    xfce4-terminal locales dmenu thunar nano \
    openssh-server \
    kali-linux-core kali-linux-default kali-tools-top10
    # kali-tools-information-gathering kali-tools-vulnerability kali-tools-web kali-tools-database kali-tools-passwords kali-tools-exploitation kali-tools-post-exploitation \
    # kali-tools-windows-resources

# Copy data to container

COPY data /data/

# Change i3 config

RUN cp /data/configs/i3-config /etc/i3/config

# Create the start bash shell file

RUN echo "#!/bin/bash" > /start.sh
RUN echo "/etc/init.d/ssh start" >> /start.sh
RUN chmod 755 /start.sh

# Create the non-root kali user

RUN useradd -m -s /bin/zsh -G sudo kali
RUN echo "kali:$PASSWORD" | chpasswd

# Change the ssh port in /etc/ssh/sshd_config

RUN echo "Port $SSH_PORT" >> /etc/ssh/sshd_config

# Install and config VNC

RUN apt -y install --no-install-recommends tigervnc-standalone-server tigervnc-tools; \
    echo "/usr/libexec/tigervncsession-start :${VNC_DISPLAY} " >> /start.sh; \
    echo "echo -e '$PASSWORD' | vncpasswd -f >/home/kali/.vnc/passwd" >> /start.sh; \
    echo "while true; do sudo -u kali vncserver -fg -v ; done" >> /start.sh; \
    echo ":${VNC_DISPLAY}=kali" >>/etc/tigervnc/vncserver.users; \
    echo '$localhost = "no";' >>/etc/tigervnc/vncserver-config-mandatory; \
    echo '$SecurityTypes = "VncAuth";' >>/etc/tigervnc/vncserver-config-mandatory; \
    mkdir -p /home/kali/.vnc; \
    chown kali:kali /home/kali/.vnc; \
    touch /home/kali/.vnc/passwd; \
    chown kali:kali /home/kali/.vnc/passwd; \
    chmod 600 /home/kali/.vnc/passwd;

# Add custom wallpaper

RUN mkdir /home/kali/.wallpapers/
COPY data/images/wallpaper.jpg /home/kali/.wallpapers/wallpaper.jpg

# Expose the right ports and set the entrypoint

RUN echo "/bin/bash" >> /start.sh

EXPOSE $SSH_PORT $XVNC_PORT
WORKDIR "/root"
ENTRYPOINT ["/bin/bash"]
CMD ["/start.sh"]
