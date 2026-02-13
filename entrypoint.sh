#!/usr/bin/env bash
set -e

# load conda functions
if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
  source /opt/conda/etc/profile.d/conda.sh
else
  echo "conda.sh not found in /opt/conda/etc/profile.d" >&2
fi

# activate lerobot env
conda activate "${LEROBOT_CONDA_ENV:-lerobot_ros2}"

# source ROS 2 and workspace overlays if present
if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then
  source /opt/ros/${ROS_DISTRO}/setup.bash
fi
if [ -f "${ROS_WS}/install/setup.bash" ]; then
  source "${ROS_WS}/install/setup.bash"
fi

# expose conda site-packages for bridge import
export LECONDA_SITE_PACKAGES="/opt/conda/envs/${LEROBOT_CONDA_ENV:-lerobot_ros2}/lib/python3.10/site-packages"
export PYTHONPATH="${LECONDA_SITE_PACKAGES}:${PYTHONPATH:-}"

# (re)create symlink to lerobot source inside bridge install site-packages (safe to run repeatedly)
LEROBOT_SRC="/opt/lerobot/src/lerobot"
BRIDGE_DEST="${ROS_WS}/install/so101_ros2_bridge/lib/python3.10/site-packages/lerobot"
if [ -d "${LEROBOT_SRC}" ]; then
  mkdir -p "$(dirname "${BRIDGE_DEST}")"
  if [ -L "${BRIDGE_DEST}" ] || [ -e "${BRIDGE_DEST}" ]; then
    rm -rf "${BRIDGE_DEST}"
  fi
  ln -s "${LEROBOT_SRC}" "${BRIDGE_DEST}" || true
fi

# execute the container command
exec "$@"