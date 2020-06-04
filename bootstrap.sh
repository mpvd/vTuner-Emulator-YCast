#!/bin/sh !/bin/sh
# by netraans
# Variables defined in dockerfile

if [ "$YC_DEBUG" = "OFF" ]; then
        /usr/bin/python3 -m ycast -c $YC_STATIONS -p $YC_PORT

elif [ "$YC_DEBUG" = "ON" ]; then
        /usr/bin/python3 -m ycast -c $YC_STATIONS -p $YC_PORT -d

else
        /bin/sh

fi
