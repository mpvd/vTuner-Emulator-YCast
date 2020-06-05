#!/bin/bash
#prepare
sudo docker stop vtuner-ycast
sudo docker rm vtuner-ycast
mkdir -p /home/vtuner/

# Build docker, this will take a while
sudo docker build -f dockerfile -t vtuner-emulator-ycast .

# run it
sudo docker run -d \
	--name vtuner-ycast \
	-v /home/vtuner/:/opt/ycast/stations/ \
	-p 8080:80 \
	--restart unless-stopped \
 vtuner-emulator-ycast
sudo chmod -R 777 /home/vtuner/

# If you have your own list put in in the same
# directory like this batch and name it stations.yml.
# The dockerfile works inside the docker and copies the
# default stations.yml.example file from the ycast tar in
# the stations directory of the docker.
# This following copy command overrides the default yml.
# If it's missing it will be ignored. 
cp stations.yml /home/vtuner/stations.yml 2>/dev/null || :


