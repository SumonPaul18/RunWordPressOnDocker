#!/bin/bash
mkdir -p /root/wordpress
cat <<EOF | sudo tee /root/wordpress/docker-compose.yml
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
      - "8000:80"
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
      device: ":/nfs-share/docker/wordpress/mysql"

  nfsvolume-wordpress:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=192.168.0.96,rw,nfsvers=4"
      device: ":/nfs-share/docker/wordpress/wordpress"
           
EOF

cd /root/wordpress/
ls
docker compose up -d
docker compose ps
