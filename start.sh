#!/bin/bash
docker create --sysctl net.ipv6.conf.all.disable_ipv6=0 --privileged --rm --name kali-linux --cap-add NET_ADMIN -v /dev/net/tun:/dev/net/tun -p 22:22 -p 5901:5901 -t and0x00/kali-linux
docker start kali-linux
