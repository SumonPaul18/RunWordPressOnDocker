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
      - /nfs-share/wordpress/mysql/:/var/lib/mysql
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
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: sysadmin
      WORDPRESS_DB_PASSWORD: centos@123
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - /nfs-share/wordpress/wpdata/:/var/www/html:rw
           
EOF

cd /nfs-share/wordpress
ls
docker compose up -d
docker compose ps
