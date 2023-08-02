#!/bin/bash

while [ -z "$PASS" ]; do
read -p "Enter the password: " PASS
done

docker build --build-arg PASSWORD="$PASS" -t and0x00/kali-linux -f Dockerfile .
