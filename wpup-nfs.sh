#!/bin/bash
mkdir -p /root/wordpress
cat <<EOF | sudo tee /root/wordpress/docker-compose.yml
version: "3.8" 
services:
  db:
    image: mysql:latest
    restart: always
    volumes:
      - nfs-mysql/mysql/:/var/lib/mysql
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
      - nfs-wordpress/wordpress/:/var/www/html
volumes:
  nfs-mysql:
     driver: local
     driver_opts:
       type: nfs
       device: ":/nfs-share/"
       o: "addr=192.168.106.4,nolock,soft,rw"

  nfs-wordpress:
     driver: local
     driver_opts:
       type: nfs
       device: ":/nfs-share/"
       o: "addr=192.168.106.4,nolock,soft,rw"
           
EOF

cd /root/wordpress/
ls
docker compose up -d
docker compose ps
