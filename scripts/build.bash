#!/usr/bin/env bash
# This script builds the podman image

set -euo pipefail

# Obtain version info
source version_info

args=("$@")

usage() {
  cat <<EOF
  Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-u] [-r] [-n] [-t]
  Script description here.
  Available options:
  -h, --help      Print this help and exit
  -u, --ubuntu    Set Ubuntu version [20/22/24]. Default 22.
  -r, --ros       Set ROS version ROS1 / ROS2 / (ROS1 + ROS2) [1/2/3]. Default 2.
  -n, --nvidia    Set true for NVIDIA cuda capabilities, otherwise false. Default true.
  -t, --runtime   Set true to build with NVIDIA runtime image, otherwise devel image. Default true.

  Example:
  ./build.bash -u 22 -r 2 -n true -t true
EOF
exit
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  msg "Use -h for more information"
  exit "$code"
}

main() {
  # Provide default values for variables
  UBUNTU_VERSION="22"
  ROS_VERSION="2"
  ENABLE_NVIDIA_CAPABILITIES="true"
  USE_RUNTIME_IMAGE="true"

  for (( a = 0; a < ${#args[@]}; a++ )); do

    if [[ ${args[$a]} == "-h" ]] || [[ ${args[$a]} == "--help" ]]; then
      usage
    elif [[ ${args[$a]} == "-u" ]] || [[ ${args[$a]} == "--ubuntu" ]]; then

      curr_arg=${args[(($a+1))]}
      if [[ $curr_arg == "20" || $curr_arg == "22" || $curr_arg == "24" ]]
      then
        UBUNTU_VERSION=$curr_arg
        ((a=a+1))
      else
        die "-u accepts [20/22/24]."
      fi

    elif [[ ${args[$a]} == "-r" ]] || [[ ${args[$a]} == "--ros" ]]; then

      curr_arg=${args[(($a+1))]}
      if [[ $curr_arg == "1" || $curr_arg == "2" || $curr_arg == "3" ]]
      then
        ROS_VERSION=$curr_arg
        ((a=a+1))
      else
        die "-r accepts ROS1 / ROS2 / (ROS1 + ROS2) [1/2/3]."
      fi

    elif [[ ${args[$a]} == "-n" ]] || [[ ${args[$a]} == "--nvidia" ]]; then

      curr_arg=${args[(($a+1))]}
      if [[ $curr_arg == "true" || $curr_arg == "false" ]]
      then
        ENABLE_NVIDIA_CAPABILITIES=$curr_arg
        ((a=a+1))
      else
        die "-n only accepts true or false."
      fi

    elif [[ ${args[$a]} == "-t" ]] || [[ ${args[$a]} == "--runtime" ]]; then

      curr_arg=${args[(($a+1))]}
      if [[ $curr_arg == "true" || $curr_arg == "false" ]]
      then
        USE_RUNTIME_IMAGE=$curr_arg
        ((a=a+1))
      else
        die "-t only accepts true or false."
      fi

    else
      die "Unknown argument '${args[$a]}'!"
    fi
  done

  user_id=$(id -u)
  if [[ $ENABLE_NVIDIA_CAPABILITIES == "true" ]]
  then
    if [[ $USE_RUNTIME_IMAGE == "true" ]]
    then
      echo -e "\nBuilding Image: ubuntu"$UBUNTU_VERSION".04:"$PACKAGE_VERSION"-cnvros"$ROS_VERSION"\n\n"
      # Build with cuda NVIDIA (runtime)
      podman build --rm -t ubuntu$UBUNTU_VERSION.04:$PACKAGE_VERSION-cnvros$ROS_VERSION-runtime --build-arg user_id=$user_id -f ../podman_build/u$UBUNTU_VERSION/cuda_runtime/ros$ROS_VERSION/Containerfile .
    else
      echo -e "\nBuilding Image: ubuntu"$UBUNTU_VERSION".04:"$PACKAGE_VERSION"-cnvros"$ROS_VERSION"-runtime""\n\n"
      # Build with cuda NVIDIA (devel)
      podman build --rm -t ubuntu$UBUNTU_VERSION.04:$PACKAGE_VERSION-cnvros$ROS_VERSION-devel --build-arg user_id=$user_id -f ../podman_build/u$UBUNTU_VERSION/cuda/ros$ROS_VERSION/Containerfile .
    fi
  else
    echo -e "\nBuilding Image: ubuntu"$UBUNTU_VERSION".04:"$PACKAGE_VERSION"-ros"$ROS_VERSION"\n\n"
    # Build without NVIDIA capabilities
    podman build --rm -t ubuntu$UBUNTU_VERSION.04:$PACKAGE_VERSION-ros$ROS_VERSION --build-arg user_id=$user_id -f ../podman_build/u$UBUNTU_VERSION/non_nvidia/ros$ROS_VERSION/Containerfile .
  fi
}

main
