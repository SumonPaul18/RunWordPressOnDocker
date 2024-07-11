## Run Wordpress On Previous Data using NFS Volume & Docker-Compose 
![WordPressOnDocker](https://github.com/SumonPaul18/RunWordPressOnDocker/blob/main/WordPressOnDocker.gif)
---
####
    mkdir wordpress1 && cd wordpress1
    cat <<EOF | sudo tee /root/wordpress1/docker-compose.yml
    version: "2.2"
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
          - "8004:80"
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
          device: ":/nfs-share/docker/wordpress1/mysql"

      nfsvolume-wordpress:
        driver: local
        driver_opts:
          type: "nfs"
          o: "addr=192.168.0.96,rw,nfsvers=4"
          device: ":/nfs-share/docker/wordpress1/wordpress"
    EOF
####
    docker compose up -d
####
    docker compose ps
####
    docker ps
