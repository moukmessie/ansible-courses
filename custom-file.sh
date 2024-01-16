#!/bin/sh

# Setting up APT
touch '/etc/apt/apt.conf.d/proxy'
chmod 644 '/etc/apt/apt.conf.d/proxy'
echo 'Acquire::http::Proxy "http://proxy.univ-lyon1.fr:3128/";' >> /etc/apt/apt.conf.d/proxy
echo 'Acquire::https::Proxy "http://proxy.univ-lyon1.fr:3128/";' >> /etc/apt/apt.conf.d/proxy

# User custom proxy settings
touch '/etc/profile.d/export-proxy.sh'
echo 'export http_proxy="http://proxy.univ-lyon1.fr:3128/"' >> /etc/profile.d/export-proxy.sh
echo 'export https_proxy="http://proxy.univ-lyon1.fr:3128/"' >> /etc/profile.d/export-proxy.sh

# Global proxy settings
chmod 644 '/etc/environment'
echo 'http_proxy="http://proxy.univ-lyon1.fr:3128/"' >> /etc/environment
echo 'https_proxy="http://proxy.univ-lyon1.fr:3128/"' >> /etc/environment
echo 'Defaults env_keep = "http_proxy https_proxy"' >> /etc/sudoers

# Wget proxy settings
#chmod 644 '/etc/wgetrc'
#echo 'http_proxy = "http://proxy.univ-lyon1.fr:3128/"' >> /etc/wgetrc
#echo 'https_proxy = "http://proxy.univ-lyon1.fr:3128/"' >> /etc/wgetrc
#echo 'use_proxy = on' >> /etc/wgetrc

apt update && apt upgrade
apt install curl htop build-essential unzip zip fish rsync

usermod -a -G sudo debian
usermod -a -G www-data debian

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfswXCysTURNTCRMrvCdd9h0obpvHoQo7Seg0/1ciBhx1UmTh1auBOoASxV29nX4ZtnVVgXwTFu1RBg4dLeGs5vw7ou/wFjuZ0XMZkVGcU1RBDo18tLIsqU2OynvJ0iB7RH5xJbkqOlgmzPraD2K2BCxX3yyT3dgPXrbiIQG+xSsUzEL5mA943Q/pqZh/Dxqh35wV/Lp5DK6FtO8piF5sOAIars1YmvfEFdsPQ8tI87u3xpz1jXvhvHXIl76YOrjGPQ17IJm6zSB01ihLyFlzZ0LbHYkL3S56D8395vJMNYUOLGhs8O/UWSjzYbw1cwRqNxWTPgBCBRtoSMiQ/2KTT2pPCIInOk8Xil7rBhFgzQ2oDHolNwiS47xaVzN3gaCGpM7RylgJ3IUVwzIAh5q7LherO9REtmqLtH1mTZCm8zcOVQtZzfg1B+78+UhDYhzrJrSA4eC1mggwqznOrFws1qTdEN1LlkozaiUcO0ICC8/U59zmrVy2PDXgF1ci37Zmy5StVZFnXyFOWWnqQ4eA2BB0T0USZWUjZdpDtySbsd7I6RaTUhB/gMk7AqZoaugG/xftCagjzFfrwHzwXMvP/r85FlN3yJ/8r6LHugtByEmlEg0+PJogo7A2YciQeAyRBGCWo3O/n/Qj0+4Tr0ka1pzDdpkBf/jScimj9wzgCiQ==' | tee -a /home/debian/.ssh/authorized_keys
