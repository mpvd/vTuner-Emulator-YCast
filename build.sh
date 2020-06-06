#!/bin/bash
# Build docker, this will take a while
VERSION=1.0

#Prepare
if [ -f "VERSION" ]; then rm VERSION 
fi
echo $VERSION > VERSION

# build docker
echo Building version: $VERSION
sudo docker build -f dockerfile -t mpvd/vtuner-emulator-ycast . 

# tag docker
echo Tagging the docker
sudo docker tag mpvd/vtuner-emulator-ycast:latest mpvd/vtuner-emulator-ycast:$VERSION

# create own network for this container which
# you can address in DNS and router later
sudo docker network create --subnet=172.18.0.0/24 multimedia 2>/dev/null

# run the docker
echo Running the Docker
mkdir -p /home/vtuner/
sh run.sh

# If you have your own list put in in the same
# directory like this batch and name it stations.yml.
# The dockerfile works inside the docker and copies the
# default stations.yml.example file from the ycast tar in
# the stations directory of the docker.
# This following copy command overrides the default yml.
# If it's missing it will be ignored. 

if [ -f "stations.yml" ]; then
    echo "stations.yml found"
	cp stations.yml /home/vtuner/stations.yml 2>/dev/null || :
	echo "stations.yml copied"
else 
    echo "No stations.yml to copy :-("
	echo "stations.yml from example will be used."
fi
