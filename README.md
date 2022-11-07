# kali-linux-docker
## how to build

    docker build --build-arg PASSWORD=%your_password% -t and0x00/kali-linux -f Dockerfile .

## how to use

    docker create --name kali-linux -p 1022:22 -t and0x00/kali-linux
    docker start kali-linux
