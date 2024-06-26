#!/bin/bash
mkdir -p /nfs-share
mount 192.168.0.96:/nfs-share /nfs-share
ls -l /nfs-share
mkdir -p /nfs-share/wordpress
mkdir -p /nfs-share/wordpress/wpdata
mkdir -p /nfs-share/wordpress/mysql
chmod 775 -R /nfs-share/wordpress
cd /nfs-share/wordpress
ls
cat <<EOF | sudo tee /nfs-share/wordpress/docker-compose.yml
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
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    restart: always
    ports:
      - "8003:80"
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
      o: "addr=192.168.0.96,rw,nfsvers=4"
      device: ":/nfs-share/wordpress/mysql"

  nfsvolume-wordpress:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=192.168.0.96,rw,nfsvers=4"
      device: ":/nfs-share/wordpress/wpdata"
           
EOF

cd /nfs-share/wordpress
ls
docker compose up -d
docker compose ps
