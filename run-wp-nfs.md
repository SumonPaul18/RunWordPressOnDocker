
## Install Wordpress On NFS Volume using Docker-Compose 
![WordPressOnDocker](https://github.com/SumonPaul18/RunWordPressOnDocker/blob/main/WordPressOnDocker.gif)
---
### Run Wordpress-MySQL      
---

#### Verify docker compose version
    docker compose version

#### Install NFS Client & Configuration with NFS Server:
    
    apt update -y
    apt install nfs-common -y
    mkdir -p /nfs-share
    chmod 777 /nfs-share
    mount 192.168.0.96:/nfs-share /nfs-share
    ls -l /nfs-share
    
    
#### Navigate to the new directory:
   
    mkdir -p /nfs-share/wordpress
    mkdir -p /nfs-share/wordpress/wordpress-data
    mkdir -p /nfs-share/wordpress/mysql
    chmod 777 -R /nfs-share/wordpress
    cd /nfs-share/wordpress
    ls

#### Create a yaml file.

    nano docker-compose.yml

#### Create a new docker-compose.yml file, and paste the contents below:

##### File Start Here with Description

    version: "3.8" 
    services:
      db: 
        image: mysql:5.7
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
          - /nfs-share/wordpress/wordpress-data/:/var/www/html

#### Save the .yml file

  
#### Docker Compose UP

    docker compose up -d

#### Check Docker Compose
    docker compose ps
#### or
    docker ps

#### Open Browser
    http://DockerHostIP:8000

#### 1st time setup the wordpress site:

    Site Title:
    User:
    Pass:
    Email:

### Now Enjoying! Your Wordpress Site.

####  Now! Check docker PS

    docker ps

#### Now! Down docker compose

    docker compose down
---
### Run Wordpress-MySql with phpMyAdmin
---
#### Create a new project directory:

    mkdir wordpress

#### Navigate to the new directory:

    cd wordpress

#### Create a yaml file.

    nano docker-compose.yml
#### Create a new docker-compose.yml file, and paste the contents below:

    version: "3"
    services:
      db:
        image: mysql:5.7
        volumes:
          - /nfs-share/wordpress/mysql/:/var/lib/mysql
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: centos@123
          MYSQL_DATABASE: wordpress
          MYSQL_USER: sysadmin
          MYSQL_PASSWORD: centos@123
        volumes:
          - $PWD/mysql/:/var/lib/mysql
      
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
          - "8080:80"
      
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
          - /nfs-share/wordpress/wordpress-data/:/var/www/html
  

#### Docker Compose UP

    docker compose up -d  

#### Check Docker Compose
        docker compose ps
#### or
        docker ps
  

#### Access phpMyAdmin Dashboard:

    http://DockerHostIp:8080/

#### Access wordpress Dashboard:
    http://DockerHostIP:8000

-- END --
