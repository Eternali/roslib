FROM osrf/ros:melodic-desktop

WORKDIR /app

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y ros-melodic-rosbridge-server

COPY . /app

