#!/bin/bash
VERSION=$(cat VERSION)

#prepare
sudo docker stop vey-$VERSION
sudo docker rm vey-$VERSION

# run it
sudo docker run -d \
	--name vey-$VERSION \
	-v /home/vtuner/:/srv/ycast/ycast/stations/ \
	-p 8081:80 \
	--net multimedia \
	--ip 172.18.0.100 \
	--restart unless-stopped \
mpvd/vtuner-emulator-ycast:$VERSION

sudo chmod -R 755 /home/vtuner
