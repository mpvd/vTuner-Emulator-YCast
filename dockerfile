# Docker Buildfile for Raspberry Pi (Raspian) 
# Image size: about 34 MB

FROM alpine:latest

MAINTAINER MPvD, https://github.com/mpvd

# Variables: (passed from build script)
# YC_VERSION version of ycast software
# YC_STATIONS* path an name of the indiviudual stations.yml e.g. /ycast/stations/stations.yml ; before changing check vtuner-build.sh
# YC_DEBUG turn ON or OFF debug output of YCast server else only start /bin/sh
# YC_PORT port ycast server listens to, e.g. 80
# Folder structure /srv/ycast/ycast/stations
ENV YC_VERSION 1.0.0
ENV YC_WORKDIR /srv/ycast
ENV YC_STATIONSFOLDER ycast/stations
ENV YC_STATIONSFILE stations.yml
ENV YC_DEBUG OFF
ENV YC_PORT 80

# Upgrade alpine Linux, install python3 and dependencies for pillow - alpine does not use glibc
# Optional nano editor installed (If you don't need it, delete this line.)
# pip install needed modules for ycast
# make directories, delete unneeded packages
# download ycast tar.gz and extract it in ycast Directory
# delete unneeded stuff
# copy stations.yml with examples
RUN apk --no-cache update \
&& apk --no-cache upgrade \
&& apk add --no-cache py-pip \
&& apk add --no-cache zlib-dev \
&& apk add --no-cache libjpeg-turbo-dev \
&& apk add --no-cache build-base \
&& apk add --no-cache python3-dev \
&& pip3 install --no-cache-dir requests \
&& pip3 install --no-cache-dir flask \
&& pip3 install --no-cache-dir PyYAML \
&& pip3 install --no-cache-dir pillow \
&& mkdir -p $YC_WORKDIR/$YC_STATIONSFOLDER \
&& mkdir /temp \
&& apk del --no-cache python3-dev \
&& apk del --no-cache build-base \
&& apk del --no-cache zlib-dev \
&& apk add --no-cache curl \
&& curl -L https://github.com/milaq/YCast/archive/$YC_VERSION.tar.gz | tar xvzC /temp \
&& apk del --no-cache curl \
&& cp -r /temp/YCast-$YC_VERSION/* $YC_WORKDIR/ \
&& rm -r /temp \
&& pip3 uninstall --no-cache-dir -y setuptools \
&& find /usr/lib -name \*.pyc -exec rm -f {} \; \
&& find /usr/lib -type f -name \*.exe -exec rm -f {} \;  \
&& rm -f /usr/lib/libsqlite* \
&& rm -f /usr/lib/libncursesw* \
&& rm -f /lib/libcrypto* \
&& rm -f /lib/libssl* \
&& rm -rf /var/lib/apt/lists/* \
&& cp $YC_WORKDIR/examples/stations.yml.example $YC_WORKDIR/$YC_STATIONSFOLDER/$YC_STATIONSFILE \
&& chmod -R 755 $YC_WORKDIR/$YC_STATIONSFOLDER/

# Set Workdirectory on ycast folder
WORKDIR $YC_WORKDIR

# important for container start
COPY entrypoint.sh /entrypoint.sh
COPY VERSION /VERSION

# Port on with Docker Container is listening
EXPOSE $YC_PORT/tcp

# Start bootstrap on container start
RUN ["sh", "-c", "chmod +x /entrypoint.sh"]
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]

#Healthcheck
HEALTHCHECK CMD ps aux | grep -i "python3 -m ycast -c /srv/ycast/ycast/stations/stations.yml -p $YC_PORT" | grep -v grep || exit 1
#curl --fail http://localhost:$YC_PORT/ || exit 1
