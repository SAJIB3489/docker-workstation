# name=Dockerfile
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=humble
ARG USER=rosuser
ARG UID=1000

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

LABEL maintainer="demo@gmail.com"

# Install base packages and basic utilities (including tzdata/locales non-interactive)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release build-essential git wget mesa-utils ssh gedit \
    locales tzdata procps file sudo python3-venv python3-pip python-is-python3 gpg \
    software-properties-common apt-transport-https \
  && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install catkin_tools
RUN pip3 install --no-cache-dir -U pip && \
    pip3 install --no-cache-dir -U typeguard

# Configure locale
RUN locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8

# Install Miniconda (multi-arch) into /home/${USER}/miniconda3
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      arm64|aarch64) installer=Miniconda3-latest-Linux-aarch64.sh ;; \
      amd64|x86_64) installer=Miniconda3-latest-Linux-x86_64.sh ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    url="https://repo.anaconda.com/miniconda/${installer}"; \
    wget -q "$url" -O /tmp/miniconda.sh; \
    bash /tmp/miniconda.sh -b -u -p /home/${USER}/miniconda3; \
    rm -f /tmp/miniconda.sh; \
    /home/${USER}/miniconda3/bin/conda init bash || true

ENV PATH=/home/${USER}/miniconda3/bin:$PATH

# Create a non-root user and give passwordless sudo
RUN useradd -m -u ${UID} -s /bin/bash ${USER} \
  && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
  && chmod 0440 /etc/sudoers.d/${USER}

# Ensure conda directory is owned by the non-root user
RUN chown -R ${UID}:${UID} /home/${USER}/miniconda3

# Accept conda Terms of Service and create environment, then clone and pip-install lerobot
RUN set -eux; \
    CONDA_BIN=/home/${USER}/miniconda3/bin/conda; \
    # configure non-interactive conda behavior
    "${CONDA_BIN}" config --set always_yes yes --set changeps1 no || true; \
    # accept TOS for the Anaconda channels used by conda installer/updates
    "${CONDA_BIN}" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true; \
    "${CONDA_BIN}" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true; \
    # update conda and create env
    "${CONDA_BIN}" update -n base -c defaults conda || true; \
    "${CONDA_BIN}" create -y -n lerobot_ros2 python=3.10; \
    "${CONDA_BIN}" install -y -n lerobot_ros2 -c conda-forge "libstdcxx-ng>=12" "libgcc-ng>=12" || true; \
    # clone lerobot and install into the conda env
    git clone https://github.com/nimiCurtis/lerobot.git /home/${USER}/lerobot; \
    chown -R ${UID}:${UID} /home/${USER}/lerobot; \
    /home/${USER}/miniconda3/envs/lerobot_ros2/bin/pip install --no-cache-dir -e "/home/${USER}/lerobot[all]" || true

# Add ROS 2 apt repository
RUN set -eux; \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
      | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS packages (desktop here; switch to ros-humble-ros-base for smaller image)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ros-humble-ros-base ros-humble-rviz2 python3-rosdep python3-rosinstall-generator python3-vcstool doxygen libssh2-1-dev libudev-dev python3-colcon-common-extensions \
  && rm -rf /var/lib/apt/lists/*

# Initialize rosdep (safe to ignore errors)
RUN rosdep init || true \
  && rosdep update || true

# Set up user environment:
RUN echo "## ROS 2 setup" >> /home/${USER}/.bashrc \
  && echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${USER}/.bashrc \
  && echo "" >> /home/${USER}/.bashrc \
  && echo "## Miniconda setup" >> /home/${USER}/.bashrc \
  && echo "source /home/${USER}/miniconda3/etc/profile.d/conda.sh" >> /home/${USER}/.bashrc \
  && echo "conda activate lerobot_ros2" >> /home/${USER}/.bashrc \
  && chown ${UID}:${UID} /home/${USER}/.bashrc

RUN chown -R ${UID}:${UID} /home/${USER}
# Make SSH available
EXPOSE 22

WORKDIR /home/${USER}
USER ${USER}

ENV PATH=/home/${USER}/miniconda3/bin:$PATH
ENV CONDA_DEFAULT_ENV=lerobot_ros2

CMD ["bash"]