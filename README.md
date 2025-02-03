# Podman NVIDIA Ubuntu ROS

This repository provides easy steps start using Podman🦭 NVIDIA on Ubuntu with ROS in a container.

## Prerequisite

Use ansible to quickly install of Podman and Nvidia container toolkit.
[Let's Go!](https://github.com/BruceChanJianLe/ansible-podman)

```bash
# For the impatient
sudo apt install ansible git -y
ansible-pull -U https://github.com/brucechanjianle/ansible-podman -K
```

## Building from Source

Run the `build.bash` in the scripts directory. Follow the instructions to build the container image.  

```bash
cd scripts
./build.bash -u 22 -r 2 -n true -t true
```

## Starting a Container

Use the start scripts in the scripts directory to start the respective containers.

```bash
cd scripts
# For example, Ubuntu 24
./start24.bash
```

## Joining a Container

Use the `join.bash` script in the scripts directory.
Follow the instructions to join a running container.
If it is in exited state, use the restart script to restart it first.  

```bash
cd scripts
./join.bash
```

## Restarting a Container

Use the `restart.bash` script in the scripts directory.
Follow the instructions to restart the stopped container.  

```bash
cd scripts
./restart.bash
```

