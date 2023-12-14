# Start by specifying a base image
FROM --platform=linux/amd64 ubuntu:latest

RUN apt-get update
RUN apt-get install -y xz-utils

COPY "./blender-4.0.2-linux-x64.tar.xz" /apps/



WORKDIR /apps
RUN tar -xf blender-4.0.2-linux-x64.tar.xz
RUN rm /apps/blender-4.0.2-linux-x64.tar.xz


RUN apt-get install -y libx11-6
RUN apt-get install -y libxrender1
RUN apt-get install -y libxxf86vm1
RUN apt-get install -y libxfixes3
RUN apt-get install -y libxi6
RUN apt-get install -y libxkbcommon0
RUN apt-get install -y libsm6
RUN apt-get install -y libgl1
RUN apt-get install -y libegl1
