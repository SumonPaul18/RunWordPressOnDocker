#!/bin/bash
bgreen='\033[1;32m'
red='\033[0;31m'
nc='\033[0m'
bold="\033[1m"
blink="\033[5m"
echo -e "${bgreen} Run WordPess-MySql-PhpAdmin on NFS Volume ${nc} "
echo
systemctl is-active --quiet nfs-common && echo -e "${bgreen} NFS-Common is Running ${nc} "
echo
read -p "$(echo -e "${bgreen}${bold}${blink}Enter NFS Storage IP: ${nc}")" NFSIP
echo -e "${bgreen} Checking NFS Storage Shared Directory  ${nc} "
showmount -e $NFSIP
echo
read -p "$(echo -e "${bgreen}${bold}${blink}Create a Directory for Mount NFS Stoarge in ("/") Directory: ${nc}")" NFSDIR
mkdir -p /$NFSDIR
echo
echo -e "${bgreen} Mount NFS Shared Directory to NFS Client Directory  ${nc} "
mount $NFSIP:/nfs-share /$NFSDIR
ll /nfs-share
read -p "$(echo -e "${bgreen}${bold}${blink}Type a Directory Name for store Wordpess: ${nc}")" WPDIR
echo
echo
lsof -i -P -n | grep docker-pr
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
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    depends_on:
      - db
    restart: always
    environment:
      PMA_HOST: db
      PMA_USER: sysadmin
      PMA_PASSWORD: centos@123
    ports:
      - "8009:80"
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
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

volumes:
  nfsvolume-mysql:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=192.168.0.96,rw,nfsvers=4"
      device: ":/nfs-share/docker/wordpress1/mysql"

  nfsvolume-wordpress:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=192.168.0.96,rw,nfsvers=4"
      device: ":/nfs-share/docker/wordpress1/wpdata"
           
EOF

cd /nfs-share/wordpress
ls
docker compose up -d
docker compose ps
