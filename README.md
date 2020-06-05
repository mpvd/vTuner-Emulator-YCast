# vTuner-Emulator-YCast

vTuner-Emulator-YCast is a docker container based on YCast for RaspberryPi (Raspbian) to replace vTuner.
Find this project on [Github](https://github.com/mpvd/vTuner-Emulator-YCast/) and on [Docker-Hub](https://hub.docker.com/r/mpvd/vtuner-emulator-ycast).
Feel free to contact me, if you have any optimization: [Report an Issue](https://github.com/mpvd/vTuner-Emulator-YCast/issues)

## YCast
YCast is a self hosted replacement for the vTuner internet radio service which many AVRs use and made by Micha LaQua (Copyright (C) 2019 Micha LaQua).
It emulates a vTuner backend to provide your AVR with the necessary information to play self defined categorized internet radio stations and listen to Radio stations listed in the [Community Radio Browser index](http://www.radio-browser.info).

Get it via [PyPI](https://pypi.org/project/ycast/) or download from [GitHub](https://github.com/milaq/YCast/releases).


**some comments from ycast:**

 * vTuner compatible AVRs don't do HTTPS. As such, YCast blindly rewrites every HTTPS station URL to HTTP. Most station providers which utilize HTTPS for their stations also provide an HTTP stream. Thus, most HTTPS stations should work.
 * The built-in bookmark function does not work at the moment. You need to manually add your favourite stations for now.

## Docker
This Docker container is based in Alpine:latest and adds Python3 to it, which bases on this Python packages:
 * `requests`
 * `flask`
 * `PyYAML`
 * `Pillow`

The following dockerfile (and bootstrap.sh) is inspired by the great work of **netraams**. Check out [netraams/ycast-docker](https://hub.docker.com/r/netraams/ycast-docker)

I tried his docker but realised the shown dockerfile wasn't up to date and I couldn't start his docker on raspbian. So I decided to use his work as basis and did some modifications. Also due to security reasons I wanted to build the docker by myself and add nano editor just for fun. (Delete the line in dockerfile if you don't like it.)


## Usage

To start your docker use this command:
```
sudo docker run -d \
	--name vtuner-ycast \
	-v /home/vtuner/:/opt/ycast/stations/ \
	-p 80:80 \
	--restart unless-stopped \
mpvd/vtuner-emulator-ycast:latest
```
or in one line (for copy paste ;-) )

```
sudo docker run -d --name vtuner-ycast -v /home/vtuner/:/opt/ycast/stations/ -p 80:80 --restart unless-stopped mpvd/vtuner-emulator-ycast:latest 
```
 Almos every device uses port 80. There you have to forward this to your container. (If it is alread in use, see the workaround below.)
 You can edit the stations.yml from your Raspbian without entering the docker. It will be mounted to folder /home/vtuner 
 This leave also room for accessing trough other webserver to edit this list.
 

### DNS entries

You need to create a manual entry in your DNS server (read 'Router' for most home users). `vtuner.com` (more specifically `*.vtuner.com`) should point to the machine YCast is running on. Alternatively, in case you only want to forward specific vendors, the following entries may be configured:

  * Yamaha AVRs: `radioyamaha.vtuner.com` (and optionally `radioyamaha2.vtuner.com`)
  * Onkyo AVRs: `onkyo.vtuner.com` (and optionally `onkyo2.vtuner.com`)
  * Denon/Marantz AVRs: `denon.vtuner.com` (and optionally `denon2.vtuner.com`)
  
 
 ### If port 80 is already blocked 
 Here is a little trick if you are already using for example pihole (or any other webserver). Then port 80 on our Rasberry Pi is blocked. But you can rewrite the vtuner.com domains to the internal ip of the docker container itself. Then all you need is a route to your Raspberry PI.  For example:
  * IP of RaspberryPi is: 192.168.178.100
  * IP of you ycast-Docker is: 172.17.0.2 (usually bridged network has a 255.255.0.0 or /16 subnet)
  * Your route in your router should be then 172.17.0.0/16 to 192.168.178.100
  
  Then you have to change the external port of the docker (the internal stays at 80). For example to 8080 or whatever you like: 
```
sudo docker run -d --name vtuner-ycast -v /home/vtuner/:/opt/ycast/stations/ -p 8080:80 --restart unless-stopped mpvd/vtuner-emulator-ycast:latest
```
Have fun. :-)
=
<br><br> 
If you want to do it yourself then read on.

## Recomendation: Build the docker on your own.

You need the following files in one folder: 
 * `vtuner-build.sh`
 * `dockerfile`
 * `bootstrap.sh`
 * `samples.yml (optional, if you already have your favorites, see vtuner-build.sh)`

#### vtuner-build.sh 
(Pay attention to the port.)

```
#!/bin/bash
#prepare
mkdir -p /home/vtuner/

# Build docker, this will take a while
sudo docker build -f dockerfile -t mpvd/vtuner-emulator-ycast .

# run it
sudo docker run -d \
		--name vtuner-ycast \
		-v /home/vtuner/:/opt/ycast/stations/ \
		-p 80:80 \
		--restart unless-stopped \
mpvd/vtuner-emulator-ycast
sudo chmod -R 777 /home/vtuner/

# If you have your own list put in in the same
# directory like this batch and name it stations.yml.
# The dockerfile works inside the docker and copies the
# default stations.yml.example file from the ycast tar in
# the stations directory of the docker.
# This following copy command overrides the default yml.
# If it's missing it will be ignored. 
cp stations.yml /home/vtuner/stations.yml 2>/dev/null || :
```

### dockerfile

```
# Docker Buildfile for Raspberry Pi (Raspian) 
# Image size: about 41.3 MB                       
# Code based on: netraans                          
# Edited by: mpvd                                      

FROM alpine:latest

# Variables:
# YC_VERSION version of ycast software
# YC_STATIONS path an name of the indiviudual stations.yml e.g. /ycast/stations/stations.yml ; before changing check vtuner-build.sh
# YC_DEBUG turn ON or OFF debug output of YCast server else only start /bin/sh
# YC_PORT port ycast server listens to, e.g. 80
ENV YC_VERSION 1.0.0
ENV YC_STATIONS /opt/ycast/stations/stations.yml
ENV YC_DEBUG OFF
ENV YC_PORT 80

# Upgrade alpine Linux, install python3 and dependencies for pillow - alpine does not use glibc
# Optional nano editor installed (If you don't need it, delete this line.)
# pip install needed modules for ycast
# make /opt/ycast Directory, delete unneeded packages
# download ycast tar.gz and extract it in ycast Directory
# delete unneeded stuff
# copy stations.yml with examples
RUN apk --no-cache update \
&& apk --no-cache upgrade \
&& apk add --no-cache nano \
&& apk add --no-cache py-pip \
&& apk add --no-cache zlib-dev \
&& apk add --no-cache libjpeg-turbo-dev \
&& apk add --no-cache build-base \
&& apk add --no-cache python3-dev \
&& pip3 install --no-cache-dir requests \
&& pip3 install --no-cache-dir flask \
&& pip3 install --no-cache-dir PyYAML \
&& pip3 install --no-cache-dir pillow \
&& mkdir -p /opt/ycast/stations \
&& apk del --no-cache python3-dev \
&& apk del --no-cache build-base \
&& apk del --no-cache zlib-dev \
&& apk add --no-cache curl \
&& curl -L https://github.com/milaq/YCast/archive/$YC_VERSION.tar.gz | tar xvzC /opt/ycast \
&& apk del --no-cache curl \
&& pip3 uninstall --no-cache-dir -y setuptools \
&& find /usr/lib -name \*.pyc -exec rm -f {} \; \
&& cp /opt/ycast/YCast-$YC_VERSION/examples/stations.yml.example $YC_STATIONS \
&& chmod -R 777 /opt/ycast/stations

# Set Workdirectory on ycast folder
WORKDIR /opt/ycast/YCast-$YC_VERSION

# Copy bootstrap.sh to /opt 
# important for container start, see below
COPY bootstrap.sh /opt

# Port on with Docker Container is listening
EXPOSE $YC_PORT/tcp

# Start bootstrap on container start
RUN ["chmod", "+x", "/opt/bootstrap.sh"]
ENTRYPOINT ["/opt/bootstrap.sh"]
```

### bootstrap.sh

```
#!/bin/sh
# by netraans
# Variables defined in dockerfile
if [ "$YC_DEBUG" = "OFF" ]; then
		/usr/bin/python3 -m ycast -c $YC_STATIONS -p $YC_PORT

elif [ "$YC_DEBUG" = "ON" ]; then
		/usr/bin/python3 -m ycast -c $YC_STATIONS -p $YC_PORT -d

else
		/bin/sh

fi
```

### stations.yml
Have a look at the provided example to better understand how the file should look like. If you run the docker, there already will be an example copied in the right place, which you can use. 

 
 ## License and warranty
  * YCast has a [GPLv3]-License and is free. Check [PyPI](https://pypi.org/project/ycast/) or [GitHub](https://github.com/milaq/YCast/releases)
  * dockerfile and bootstrap.sh based on [netraams/ycast-docker](https://hub.docker.com/r/netraams/ycast-docker)
  * more info about [Flask](https://flask.palletsprojects.com/en/1.1.x/) and the [License](https://github.com/pallets/flask/blob/master/LICENSE.rst)
  * Also this docker/code is distributed in the hope that it will be useful, but without any warranty. You use it at our own risk. 
  
 ## ToBe done in Future
  * If you open the YCast server in your browser, it shows strange codes. It would be cool, if it would show the stations.yml
  * Editable stations.yml in browser: Right know you have to edit it from your Raspberry
  * If you change the stations.yml you have to reboot the server. I think this is caused by Flask. As far as I know it should run in debug-mode, to make this possible. But didn't had time to go deeper. 
  * As far as I understand YCast 1.0.0 is using the old API of Radio Browser. I don't know why, but maybe this will be an issue in Future. 
  
Feel free to contact me, if you have any optimization: [Report an Issue](https://github.com/mpvd/vTuner-Emulator-YCast/issues)
