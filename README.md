# Raspberry Pi REDHAWK Docker
A basic [Docker](https://www.docker.com/) image of a [REDHAWK](http://redhawksdr.org) environment for the [Raspberry Pi](http://www.raspberrypi.org/).  

The image builds the REDHAWK core framework from source as there are no ARM based packages available for the Pi currently.  This image will NOT run on an x86 based platform and must be built and run on a Raspberry Pi.  For information on installing docker on your Pi see the [Hypriot Blog Post](http://blog.hypriot.com/heavily-armed-after-major-upgrade-raspberry-pi-with-docker-1-dot-5-0).

The image can be pulled from the [Docker Hub Registry](https://registry.hub.docker.com/u/axios/rpi-redhawk/)

The image has no default command and is meant to be used as a base image for future REDHAWK application docker images.

The image comes with the omniNames and omniEvents servers installed and configured.  Start them with:

    service omniorb4-nameserver start
    service omniorb-eventservice start

