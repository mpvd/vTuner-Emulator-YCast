#!/bin/sh
# Variables defined in dockerfile or in build script
echo "Booted succesfully, alpine is running."
echo "Version of docker container: $(cat /VERSION)"
echo "Version of YCast Server: $YC_VERSION"
echo 
echo "Starting server, let's see what happens:"

#run the server
if [ "$YC_DEBUG" = "ON" ]; then
    /usr/bin/python3 -m ycast -c $YC_WORKDIR/$YC_STATIONSFOLDER/$YC_STATIONSFILE -p $YC_PORT -d
	
else
	/usr/bin/python3 -m ycast -c $YC_WORKDIR/$YC_STATIONSFOLDER/$YC_STATIONSFILE -p $YC_PORT

fi

# if you can read the following, something crashed
echo "D'oh!"
echo "I'm not feeling good :-("
echo "Python, YCast-server or both crashed..." 
