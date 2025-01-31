#!/usr/bin/env bash
# This script joins current terminal to specific podman container

# Display all container's name
echo "List of containers:"
declare -a arr
i=0

# Make container name into an array
containers=$(podman ps -a | grep Up | awk '{print$NF}')
if [[ -z $containers ]]
then
  echo "  - No running containers found, to start/restart a container, use the start/restart scripts."
  exit 0
else
  for container in $containers
  do
    arr[$i]=$container
    let "i+=1"
  done
fi

# Loop through name array
let "i-=1"
for j in $(seq 0 $i)
do
    echo $j")" ${arr[$j]}
done

# Obtain container name
read -p "Container name to be connected: " CONTAINERNAME
read -p "Join with Bash / Zsh? [B/z] " value

if [[ -z $value || $value == b || $value == B ]]
then
    SELECTED_SHELL=bash
else
    SELECTED_SHELL=zsh
fi

if [[ -z ${arr[$CONTAINERNAME]} ]]
then
    podman exec --privileged -e DISPLAY=${DISPLAY} -ti $CONTAINERNAME $SELECTED_SHELL
else
    podman exec --privileged -e DISPLAY=${DISPLAY} -ti ${arr[$CONTAINERNAME]} $SELECTED_SHELL
fi
