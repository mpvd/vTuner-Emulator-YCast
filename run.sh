#!/bin/bash
#prepare
sudo docker stop vtuner-ycast
sudo docker rm vtuner-ycast

# run it
sudo docker run -d \
	--name vtuner-ycast \
	-v /home/vtuner/:/srv/ycast/ycast/stations/ \
	-p 8080:80 \
	--net multimedia \
	--ip 172.18.0.100 \
	--restart unless-stopped \
mpvd/vtuner-emulator-ycast

sudo chmod -R 777 /home/vtuner
