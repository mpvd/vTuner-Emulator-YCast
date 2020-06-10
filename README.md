# vTuner-Emulator-YCast

vTuner-Emulator-YCast is a docker container for RaspberryPi (Raspbian) based on YCast to replace vTuner.
* Find this project on [Github](https://github.com/mpvd/vTuner-Emulator-YCast/) 
* and on [Docker-Hub](https://hub.docker.com/r/mpvd/vtuner-emulator-ycast)
* Feel free to contact me, if you have any optimization: [Report an Issue](https://github.com/mpvd/vTuner-Emulator-YCast/issues)

## Usage

To start your docker use this command:
```
sudo docker run -d --name vtuner-ycast -v /home/vtuner/:/srv/ycast/ycast/stations/ -p 80:80 --restart unless-stopped mpvd/vtuner-emulator-ycast:latest 
```
 Almost every device uses port 80. There you have to forward this to your container. (If it is alread in use, see the workaround below.)
 You can edit the stations.yml from your Raspbian without entering the docker. It will be mounted to folder /home/vtuner 
 This leave also room for accessing trough other webserver to edit this list.
 
## Tips and tricks 
### DNS entries

You need to create a manual entry in your DNS server (read 'Router' for most home users). `vtuner.com` (more specifically `*.vtuner.com`) should point to the machine YCast is running on. Alternatively, in case you only want to forward specific vendors, the following entries may be configured:

  * Yamaha AVRs: 
	- `radioyamaha.vtuner.com` 
	- `radioyamaha2.vtuner.com`
  * Onkyo AVRs: 
	- `onkyo.vtuner.com` 
	- `onkyo2.vtuner.com`
  * Denon/Marantz AVRs: 
	- `denon.vtuner.com`
	- `denon2.vtuner.com`
  * and additionally for all AVRs:
	- `logo.vtuner.net`
  
 
 ### If port 80 is already blocked due to parallel use with for example Pihole 
  Here is a little trick if you are already using for example pihole (or any other webserver). Then port 80 on our Rasberry Pi is blocked. But you can rewrite the vtuner.com domains to the internal ip of the docker container itself. Then all you need is a route to your Raspberry PI.  For example:
  * IP of RaspberryPi is: 192.168.178.100
  * IP of you ycast-Docker is: 172.18.0.100 (usually bridged network has a 255.255.255.0 or /24 subnet)
  * Your route in your router should be then 172.18.0.0/24 to 192.168.178.100
  
Then you have to change the external port of the docker (the internal stays at 80). For example to 8080 or whatever you like: 
```
sudo docker run -d [...] -p 8080:80 [...] mpvd/vtuner-emulator-ycast:latest
```
Check my ```build.sh``` and ```run .sh``` for more details. 

Have fun. :-)
=
<br><br> 
## Compontents
### YCast
YCast is a self hosted replacement for the vTuner internet radio service which many AVRs use and made by **Micha LaQua** (Copyright (C) 2019 Micha LaQua).
It emulates a vTuner backend to provide your AVR with the necessary information to play self defined categorized internet radio stations and listen to Radio stations listed in the [Community Radio Browser index](http://www.radio-browser.info). 
Get YCast via [PyPI](https://pypi.org/project/ycast/) or download from [GitHub](https://github.com/milaq/YCast/releases).


Some comments from ycast:

 * vTuner compatible AVRs don't do HTTPS. As such, YCast blindly rewrites every HTTPS station URL to HTTP. Most station providers which utilize HTTPS for their stations also provide an HTTP stream. Thus, most HTTPS stations should work.
 * The built-in bookmark function does not work at the moment. You need to manually add your favourite stations for now.

### Docker
This Docker container is based in Alpine:latest and adds Python3 to it, which bases on this Python packages:
 * `requests`
 * `flask`
 * `PyYAML`
 * `Pillow`

The following dockerfile is inspired by the great work of **netraams**. Check out [netraams/ycast-docker](https://hub.docker.com/r/netraams/ycast-docker).

I tried his docker but realised the shown dockerfile wasn't up to date and I couldn't start his docker on raspbian. So I decided to use his work as basis and did some modifications. Also due to security reasons I wanted to build the docker by myself.

## Build the docker on your own

You need the following files in one folder: 
 * `run.sh`
 * `build.sh`
 * `dockerfile`
 * `bootstrap.sh`
 * `VERSION`
 * `samples.yml (optional, if you already have your favorites, add them. Have a look at the provided example to better understand how the file should look like. Don't worry if you don't have one, during building process there already will be an example copied in the right place, which you can use.)`

 
## License and warranty
  * YCast has a [GPLv3]-License and is free. Check [PyPI](https://pypi.org/project/ycast/) or [GitHub](https://github.com/milaq/YCast/releases)
  * dockerfile and bootstrap.sh based on [netraams/ycast-docker](https://hub.docker.com/r/netraams/ycast-docker)
  * more info about [Flask](https://flask.palletsprojects.com/en/1.1.x/) and the [License](https://github.com/pallets/flask/blob/master/LICENSE.rst)
  * Also this docker/code is distributed in the hope that it will be useful, but without any warranty. You use it at our own risk. 
  
## ToBe done in Future
  * If you open the YCast server in your browser, it shows strange codes. It would be cool, if it would show the stations.yml
  * Editable stations.yml in browser: Right know you have to edit it from your Raspberry
  * As far as I understand YCast 1.0.0 is using the old API of Radio Browser. I don't know why, but maybe this will be an issue in Future. 
  
Feel free to contact me, if you have any optimization: [Report an Issue](https://github.com/mpvd/vTuner-Emulator-YCast/issues)

## Release Notes
  * 1.1: Reduced Image size, healthcheck implemented, optimized folder structure and file names, VERSION file integrated 
  * 1.0: Initial build, YCast 1.0.0