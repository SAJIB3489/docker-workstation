docker run \
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
