#!/bin/bash
echo "make folder"
mkdir -p www
echo " get docker"
#curl -fsSL https://get.docker.com -o get-docker.sh
echo "get certbot"
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update -y
sudo apt-get install certbot -y
#
echo "start nginx"
docker run --name certbot --mount type=bind,source=$(pwd)/www,target=/usr/share/nginx/html -p 80:80 -d nginx
# 
echo "done"