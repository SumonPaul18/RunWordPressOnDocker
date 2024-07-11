## Run Wordpress On Previous Data using NFS Volume & Docker-Compose 
![WordPressOnDocker](https://github.com/SumonPaul18/RunWordPressOnDocker/blob/main/WordPressOnDocker.gif)
---
####
    mkdir wordpress && cd wordpress
    cat <<EOF | sudo tee /root/wordpress/docker-compose.yml
    version: "2.2"
    services:
      db:
        image: mysql:5.7
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
          - "8009:80"  
      wordpress:
        depends_on:
          - db
        image: wordpress:latest
        restart: always
        ports:
          - "8011:80"
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
          device: ":/nfs-share/docker/wordpress-data/mysql"

      nfsvolume-wordpress:
        driver: local
        driver_opts:
          type: "nfs"
          o: "addr=192.168.0.96,rw,nfsvers=4"
          device: ":/nfs-share/docker/wordpress-data/wordpress"
    EOF
####
    docker compose up -d
####
    docker compose ps
####
    docker ps
