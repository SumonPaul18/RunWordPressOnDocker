#!/bin/bash
bgreen='\033[1;32m'
red='\033[0;31m'
nc='\033[0m'
bold="\033[1m"
blink="\033[5m"
echo -e "${bgreen}Create a Directory For Store WordPess ${nc} "
echo
echo
ll /nfs-share
read -p "$(echo -e "${bgreen}${bold}${blink}Type a Directory Name for store Wordpess: ${nc}")" WPDIR
echo
echo
read -p "$(echo -e "${bgreen}${bold}${blink}Type Unused Port For Browse WordPess: ${nc}")" WPPORT
mkdir -p /nfs-share/docker/$WPDIR
mkdir -p /nfs-share/docker/$WPDIR
mkdir -p /nfs-share/docker/$WPDIR/wpdata
mkdir -p /nfs-share/docker/$WPDIR/mysql
chmod 775 -R /nfs-share/docker/$WPDIR
cd /nfs-share/docker/$WPDIR
ls
cat <<EOF | sudo tee /nfs-share/docker/$WPDIR/docker-compose.yml
version: "3.8" 
services:
  db:
    image: mysql:latest
    restart: always
    volumes:
      - /nfs-share/docker/$WPDIR/mysql/:/var/lib/mysql:rw
    environment:
      MYSQL_ROOT_PASSWORD: centos@123
      MYSQL_DATABASE: wordpress
      MYSQL_USER: sysadmin
      MYSQL_PASSWORD: centos@123
  $WPDIR:
    depends_on:
      - db
    image: $WPDIR:latest
    restart: always
    ports:
      - "$WPPORT:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: sysadmin
      WORDPRESS_DB_PASSWORD: centos@123
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - /nfs-share/docker/$WPDIR/wpdata/:/var/www/html:rw
           
EOF

cd /nfs-share/docker/$WPDIR
ls
docker compose up -d
docker compose ps
