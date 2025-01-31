#!/usr/bin/env bash
# This script starts ubuntu 20 container

set -euo pipefail

# Obtain version info
source version_info

# Allowing container to connect to x server for display
XAUTH=/tmp/.podman.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist $DISPLAY)
    xauth_list=$(sed -e 's/^..../ffff/' <<< "$xauth_list")
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

# Exit if x11 socket is not found
if [ ! -f $XAUTH ]
then
  echo "[$XAUTH] was not properly created. Exiting..."
  exit 1
fi

CONTAINER_OPTS="--device nvidia.com/gpu=all"
UBUNTU_VERSION="20"
ROS_VERSION="2"
image=""

read -p "With / Without NVIDIA Container Toolkit [Y/n]? " value

# NVIDIA Container Toolkit check
if [[ -z $value || $value == y || $value == Y ]]
then

  read -p "Which ROS version of ubuntu"$UBUNTU_VERSION".04:"$PACKAGE_VERSION"-cnvros[1/2/3]? " value
  image="ubuntu"$UBUNTU_VERSION".04:"$PACKAGE_VERSION"-cnvros"
  if [[ -z $value || $value == 1 || $value == Y ]]
  then
      echo "No ROS version selected! Defaulting to 1"
      ROS_VERSION=1
  elif [[ $value == 2 ]]
  then
      ROS_VERSION=2
  elif [[ $value == 3 ]]
  then
      ROS_VERSION=3
  else
      echo "Only 1/2/3 available!"
      exit 1
  fi
  image+=$ROS_VERSION

  read -p "y for runtime, otherwise,  n for devel image [Y/n]?" value
  if [[ -z $value || $value == y || $value == Y ]]
  then
      image+="-runtime"
  else
      image+="-devel"
  fi

  # Start container
  read -p "Container name: " CONTAINERNAME

  podman run -it \
    -d \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY=$XAUTH \
    -v "$XAUTH:$XAUTH" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/dev/input:/dev/input" \
    -v "/media:/media" \
    -v $(pwd)/../podman_mount:/home/developer/podman_mount \
    --privileged \
    --security-opt seccomp=unconfined \
    --network host \
    --pid host \
    --name $CONTAINERNAME \
    $CONTAINER_OPTS \
    $image

else

  echo -e "Image without NVIDIA Container Toolkit is currently not supported."
  echo -e "Exiting now..."

fi
