#!/bin/sh
# by netraans
# Variables defined in dockerfile or in build script

if [ "$YC_DEBUG" = "OFF" ]; then
        /usr/bin/python3 -m ycast -c $YC_WORKDIR/$YC_STATIONSFOLDER/$YC_STATIONSFILE -p $YC_PORT

elif [ "$YC_DEBUG" = "ON" ]; then
        /usr/bin/python3 -m ycast -c $YC_WORKDIR/$YC_STATIONSFOLDER/$YC_STATIONSFILE -p $YC_PORT -d

else
        /bin/sh

fi
