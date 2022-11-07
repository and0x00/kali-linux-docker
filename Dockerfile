# #####################################################
# and0x00/kali-linux
# #####################################################

FROM kalilinux/kali-rolling

ARG PASSWORD

ARG PKG
ENV PKG kali-tools-web

ENV DEBIAN_FRONTEND noninteractive
ENV SSH_PORT 22

# #####################################################
# Install packages that we always want
# #####################################################

RUN apt update -q --fix-missing
RUN apt upgrade -y
RUN apt -y install --no-install-recommends sudo wget curl dbus-x11 xinit kali-desktop-i3-gaps

# #####################################################
# Config i3-gaps
# #####################################################

COPY config /etc/i3/config

# #####################################################
# Install additional packages
# #####################################################

RUN apt -y install --no-install-recommends xfce4-terminal dmenu thunar nano

# #####################################################
# Create the start bash shell file
# #####################################################

RUN echo "#!/bin/bash" > /startkali.sh
RUN echo "/etc/init.d/ssh start" >> /startkali.sh
RUN chmod 755 /startkali.sh

# #####################################################
# Install the Kali Packages
# #####################################################

RUN apt -y install --no-install-recommends kali-linux-default $PKG

# #####################################################
# Set language
# #####################################################

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# #####################################################
# Create the non-root kali user
# #####################################################

RUN useradd -m -s /bin/bash -G sudo kali
RUN echo "kali:$PASSWORD" | chpasswd

# #####################################################
# Change the ssh port in /etc/ssh/sshd_config
# #####################################################

RUN echo "Port $SSH_PORT" >> /etc/ssh/sshd_config

# #############################
# Install and configure x2go
# x2go uses ssh
# #############################

RUN apt -y install --no-install-recommends x2goserver \
    && echo "/etc/init.d/x2goserver start" >> /startkali.sh

# ###########################################################
# The /startkali.sh script may terminate, i.e. if we only 
# have statements inside it like /etc/init.d/xxx start
# then once the startscript has finished, the container 
# would stop. We want to keep it running though.
# therefore I just call /bin/bash at the end of the start
# script. This will not terminate and keep the container
# up and running until it is stopped.
# ###########################################################

RUN echo "/bin/bash" >> /startkali.sh

# ###########################################################
# Expose the right ports and set the entrypoint
# ###########################################################

EXPOSE $SSH_PORT
WORKDIR "/root"
ENTRYPOINT ["/bin/bash"]
CMD ["/startkali.sh"]