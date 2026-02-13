# Docker Container as a Workstation

This repositor contains ready-made ubunutnu versions with bunches of software and packages as a user workstation. Select your desire workspace from below table.

| Description                           | Dockerfile                                   | Docker Image                                      |
| ------------------------------------- | -------------------------------------------- | ------------------------------------------------- |
| Ubuntu 22.04 base                     | [Dockerfile](/Dockerfile.base22.04.headless) | `docker pull ghcr.io/sajib3489/ubuntu-base:22.04` |
| Ubuntu 22.04 , ROS2 humble, Miniconda | [Dockerfile](/Dockerfile.22-04-humble-conda) | `docker pull ghcr.io/sajib3489/ubuntu-base:22.04` |

## Create a container

1. Create container without [X11 Forwarding](https://goteleport.com/blog/x11-forwarding/)

```bash
docker run -it \
 --name <MY_CONTAINER_NAME> \
 --restart=unless-stopped \
 <IMAGE_NAME>
```

2. Create container with [X11 Forwarding](https://goteleport.com/blog/x11-forwarding/)

```bash
docker run -it \
 --name <MY_CONTAINER_NAME> \
 --network=host \
 --privileged \
 --restart=unless-stopped \
 -e DISPLAY=$DISPLAY \
 -e QT_X11_NO_MITSHM=1 \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 <IMAGE_NAME>
```

**Extra shotcuts when create a container**

| Description                      | Command                 |
| -------------------------------- | ----------------------- |
| Create a container in detch mode | `docker run -dit .....` |
|                                  |                         |

```bash
docker run -it \
 --name so101_teleop \
 --network=host \
 --privileged \
 --restart=unless-stopped \
 -e DISPLAY=$DISPLAY \
 -e QT_X11_NO_MITSHM=1 \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v /dev:/dev \
 -v $HOME/so101_ros2:/root/ros2_ws/src/so101_ros2 \
 rpi-so101:latest



docker run \
 --network=host \
 --privileged \
 --restart=unless-stopped \
 -e DISPLAY=$DISPLAY \
 -e QT_X11_NO_MITSHM=1 \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 rpi-so101:latest

docker run \
 -it \
 --network=host \
 --privileged \
 -e DISPLAY=$DISPLAY \
 -e QT_X11_NO_MITSHM=1 \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 rpi-so101:latest

docker run \
 -it \
 --network=host \
 --privileged \
 -e DISPLAY=$DISPLAY \
 -e QT_X11_NO_MITSHM=1 \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 ubuntu-22-04:base

export LECONDA_SITE_PACKAGES=/home/rosuser/miniconda3/envs/lerobot_ros2/lib/python3.10/site-packages
export LEROBOT_SRC=/home/rosuser/lerobot/src/lerobot
export SO101BRIDGE_INSTALL_SITE_PACKAGES=/home/rosuser/ros2_ws/install/so101_ros2_bridge/lib/python3.10/site-packages/lerobot
ln -s $LEROBOT_SRC $SO101BRIDGE_INSTALL_SITE_PACKAGES
```
