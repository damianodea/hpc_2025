#######################################
# code from Daniele Cesini with some comments

####### INSTALL DOCKER on a RHEL9.3VM 
#######################################

  #install vim and wget -> vim is to work directly with text files
yum install vim wget

  #install the docker repo
vim /etc/yum.repos.d/docker-ce.repo
  #####################################################
  #########
  # it will open a vim window in the bash
  # press i to put it in Insert mode
  #   Add the following content in the docker-ce-repo file:

[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/rhel/9/x86_64/stable/
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/rhel/gpg

#############################################################
  # then press esc to get out from Insert mode
  # and finally type ":wq" that means write and quit
  # now you're out

  # install dependencies (maybe more will be needed, check for errors)
yum install yum-utils device-mapper-persistent-data lvm2
yum install container-selinux

  # install docker
yum install docker-ce docker-ce-cli containerd.io
wget https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 docker-compose
chmod +x docker-compose
mv docker-compose /usr/local/bin/

  #start docker
systemctl status docker
systemctl start docker
systemctl status docker
systemctl enable docker

  # now you should give to users that need to use docker the docker group
usermod -g docker <username> # not needed for user root

################################
#### INSTALLATION COMPLETE
################################

#######################
#### start using docker
#######################

docker --version
docker search ubuntu
docker pull ubuntu
docker run ubuntu echo "hello from the container"
docker run -i -t  ubuntu /bin/bash
  #### now you are in a shell running inside the container, remember to exit to go back in the host shell: type exit or Ctrl+D
docker images
time docker run ubuntu echo "hello from the container"
docker run ubuntu ping www.google.com
  # it won't work bc ping is not installed -> install ping
docker run ubuntu /bin/bash -c "apt update; apt -y install iputils-ping"
docker run ubuntu ping www.google.com
  # it won't work neither bc ping is installed in the container
docker ps
docker ps -a 
docker images
docker commit <get the container ID using docker ps -a> ubuntu_with_ping
  # now you installed ping into the image as requested
  # but be careful to spot the right image in which you installed it, bc there may be more eith the same name
docker images
docker run ubuntu_with_ping ping www.google.com
docker system df
  # the following deletes all stopped containers (not running ones)
docker system prune
docker images
docker ps -a


########## Interacting with docker-hub
docker login -u <your_username>
docker images
docker tag <image_number_ID> damianodea/hpp_repo:ubuntu_with_ping_1.0
docker push damianodea/hpc_repo:ubuntu_with_ping_1.0

  # well done! you have put ubuntu_with_ping_1.0 in your docker-hub repository


############################################
  ### Bulding docker images using Dockerfiles (it is a textfile, instead of doing many actions by hand)

vim Dockerfile
vim index.html
mkdir -p containers/simple
  # now copy the two files into the new directory
cp Dockerfile index.html containers/simple/
  # and enter the directory
cd containers/simple/

  #########################################
  #The Dockerfile ....
  [root@ip-172-31-82-181 simple]# cat Dockerfile
FROM ubuntu
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y apache2
ENV DEBIAN_FRONTEND=noninteractive
COPY index.html /var/www/html/
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
  #############################################
  # The index.html file
  [root@ip-172-31-82-181 simple]# cat index.html
<!DOCTYPE html>
<html>
<h1>Hello from a web server running inside a container!</h1>

This is an exercise for the HPQC Master.
</html>
  ###############################################

docker images
  # now build the new image using the Dockerfile
docker build -t ubuntu_web_server .
  # the dot is to build the image taking the files that are inside the directory
docker images
  # get the list of all existing containers, even stopped ones
docker ps -a
  # we can now run our new image in the background (flag -d)
docker run -d -p 8080:80 ubuntu_web_server
  # get the list of running only containers
docker ps
ifconfig
docker stop e960d33524a0
  ### Check that everything works opening in a browser this page: http://<VirtualMachine_ip_address>:8080/
  #### PAY ATTENTION TO THE SECURITY GROUP
  # to attach a shell...

docker exec -ti  <docker ID> /bin/bash   (exit with ctrl+D)

####################################
####  DOCKER VOLUMES

# map a local directory
mkdir -p $HOME/containers/scratch 
cd $HOME/containers/scratch
head -c 10M < /dev/urandom > dummy_file
docker run -v $HOME/containers/scratch/:/container_data -i -t ubuntu /bin/bash
#### try: ll /container_data from inside the container

##################################################
######### attach a volume to a docker container
##################################################

docker volume create some-volume

docker volume ls 
docker volume inspect some-volume
  # the following line is to remove it if you want
docker volume rm some-volume

docker run -i -t --name myname -v some-volume:/app ubuntu /bin/bash
docker volume rm <volume_name>
docker volume prune

## Moving images 
docker save -o my_exported_image.tar my_local_image
# docker save my_local_image | gzip > my_exported_image.tar.gz
docker load -i my_exported_image.tar



#########################################

[root@ip-172-31-20-202 hostdir]# cd
[root@ip-172-31-20-202 ~]# ls
containers  Dockerfile  hostdir  index.html
[root@ip-172-31-20-202 ~]# cd containers/
[root@ip-172-31-20-202 containers]# ls
simple
[root@ip-172-31-20-202 containers]# cd simple/
[root@ip-172-31-20-202 simple]# ls
Dockerfile  index.html
[root@ip-172-31-20-202 simple]# vim docker-compose.yml
[root@ip-172-31-20-202 simple]# ls
docker-compose.yml  Dockerfile  index.html
[root@ip-172-31-20-202 simple]# 

#


#########  DOCKER COMPOSE
#########################################

[root@ip-172-31-82-181 simple]# cat docker-compose.yml
version: '3'
services:
   database:
      image: mysql:5.7
      environment:
         - MYSQL_DATABASE=wordpress
         - MYSQL_USER=wordpress
         - MYSQL_PASSWORD=testwp
         - MYSQL_RANDOM_ROOT_PASSWORD=yes
      networks:
         - backend
   wordpress:
      image: wordpress:latest
      depends_on:
         - database
      environment:
         - WORDPRESS_DB_HOST=database:3306
         - WORDPRESS_DB_USER=wordpress
         - WORDPRESS_DB_PASSWORD=testwp
         - WORDPRESS_DB_NAME=wordpress
      ports:
         - 8080:80
      networks:
         - backend
         - frontend
networks:
    backend:
    frontend:

#########################################


docker-compose up --build --no-start
docker-compose start
  # now you can go to browser and type <public_id of the instance>:8080
  # check to edit the security rules
docker-compose stop
docker-compose down
docker images
docker system prune
