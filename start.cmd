@echo off
del $home\ssh\known_hosts ::delete X2Go known hosts
docker build --build-arg PASSWORD=%your_password%  -t and0x00/kali-linux -f Dockerfile .
docker create --name kali-linux -p 1022:22 -t and0x00/kali-linux
docker start kali-linux