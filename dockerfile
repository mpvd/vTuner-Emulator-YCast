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
