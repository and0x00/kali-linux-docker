@echo off
del $home\ssh\known_hosts ::delete X2Go known hosts
docker build --build-arg PASSWORD=%your_password%  -t kali-linux-default -f Dockerfile .
docker create --name kali-linux -p 1022:22 -t kali-linux-default
docker start kali-linux