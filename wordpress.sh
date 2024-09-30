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
read -p "$(echo -e "${bgreen}${bold}${blink}Choose Directory Where Mount with This Host, Example:-As you see same as typing(/nfs-share): ${nc}")" NFSDIR
mkdir -p $NFSDIR
echo
echo -e "${bgreen} Mount NFS Shared Directory to NFS Client Directory  ${nc} "
mount $NFSIP:$NFSDIR $NFSDIR
echo
ll $NFSDIR
read -p "$(echo -e "${bgreen}${bold}${blink}Create a Directory in NFS Storage for store Wordpess Data: ${nc}")" WPDIR
echo
lsof -i -P -n | grep docker-pr
echo
read -p "$(echo -e "${bgreen}${bold}${blink}Type Unused Port For WordPess Site Browsing: ${nc}")" WPPORT
echo
read -p "$(echo -e "${bgreen}${bold}${blink}Type Unused Port For PHP-Admin Site Browsing: ${nc}")" PHPADMINPORT
mkdir -p $NFSDIR/$WPDIR
chmod 775 -R $NFSDIR/$WPDIR
mkdir -p $NFSDIR/$WPDIR/wpdata
mkdir -p $NFSDIR/$WPDIR/mysql
cd $NFSDIR/$WPDIR
ls
cat <<EOF | sudo tee $NFSDIR/$WPDIR/docker-compose.yml
version: "3.8"
services:
  db:
    image: mysql:latest
    restart: always
    volumes:
      - nfsvolume-mysql:/var/lib/mysql:rw
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
      - "$PHPADMINPORT:80"
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
      - nfsvolume-wordpress:/var/www/html:rw

volumes:
  nfsvolume-mysql:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=$NFSIP,rw,nfsvers=4"
      device: ":$NFSDIR/$WPDIR/mysql"

  nfsvolume-wordpress:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=$NFSIP,rw,nfsvers=4"
      device: ":$NFSDIR/$WPDIR/wpdata"

EOF

cd $NFSDIR/$WPDIR
ls
docker compose up -d
docker compose ps
