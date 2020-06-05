#!/bin/bash
#prepare
sudo docker stop vtuner-ycast
sudo docker rm vtuner-ycast

# run it
sudo docker run -d \
	--name vtuner-ycast \
	-v /home/vtuner/:/opt/ycast/stations/ \
	-p 8080:80 \
	--restart unless-stopped \
 vtuner-emulator-ycast
