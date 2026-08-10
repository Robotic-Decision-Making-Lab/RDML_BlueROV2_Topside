# syntax=docker/dockerfile:1
ARG CUDA_VERSION=13.3.0
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu24.04

ARG ROS_DISTRO=jazzy
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive
ENV PROJECT_NAME=topside

# set the timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get -q update \
    && apt-get -q -y upgrade \
    && apt-get -q install --no-install-recommends -y \
    git \
    sudo \
    clang \
    python3-pip \
    python3-dev \
    python3-venv \
    apt-utils \
    build-essential \
    wget \
    curl \
    software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# install ROS 2
RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" \
    && sudo dpkg -i /tmp/ros2-apt-source.deb \
    && apt-get -q update \
    && apt-get -q -y upgrade \
    && apt-get -q install --no-install-recommends -y \
    ros-dev-tools \
    ros-$ROS_DISTRO-ros-base \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# configure and switch to the ubuntu non-root user
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -a -G dialout $USERNAME
USER $USERNAME
ENV USER=$USERNAME

# copy the project files
ENV USER_WORKSPACE=/home/$USERNAME/ws_ros
WORKDIR $USER_WORKSPACE
COPY --chown=$USER_UID:$USER_GID . src/$PROJECT_NAME

# install and configure uv
ENV VIRTUAL_ENV=$USER_WORKSPACE/topside-venv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_LINK_MODE=copy

# configure the openssh client
#
# we need this to clone any private repositories that we are using for testing.
# those private repositories will generally be managed by uv.
RUN sudo apt-get update && sudo apt-get install -y openssh-client
RUN mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts && \
    chmod 644 ~/.ssh/known_hosts

# install python dependencies
COPY --chown=$USER_UID:$USER_GID pyproject.toml ./
RUN --mount=type=ssh,uid=1000 \
    uv venv --system-site-packages $VIRTUAL_ENV \
    && uv sync --active \
    && echo "source ${VIRTUAL_ENV}/bin/activate" >> /home/$USERNAME/.bashrc \
    && touch $VIRTUAL_ENV/COLCON_IGNORE
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN echo "export PYTHONPATH=\"\${PYTHONPATH}:${VIRTUAL_ENV}/lib/python3.14/site-packages\"" >> /home/$USERNAME/.bashrc

# install all ROS dependencies
WORKDIR $USER_WORKSPACE
RUN sudo apt-get -q update \
    && sudo apt-get -q -y upgrade \
    && sudo rosdep init \
    && rosdep update \
    && rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# install and configure the text-to-speech system
RUN sudo apt-get -q update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get install -y -qq --no-install-recommends \
    espeak-ng \
    libespeak1 \
    alsa-base \
    alsa-utils \
    libasound2-dev \
    acl \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*
COPY .devcontainer/asound.conf /etc/asound.conf
RUN sudo usermod -aG audio $USER

# install and configure NVIDIA software needed for GPU access
WORKDIR /home/$USERNAME
RUN sudo apt-get update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    libxcb-cursor0 \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
ENV QT_X11_NO_MITSHM=1

WORKDIR $USER_WORKSPACE
RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && uv run --active colcon build

RUN echo "source ${USER_WORKSPACE}/install/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "\n# Ensure colcon is run in the venv\nalias colcon='uv run --active colcon'" >> /home/$USERNAME/.bashrc \
    && echo "\n# aliases for ros2 commands\nalias cbs='colcon build && source install/setup.bash'" >> /home/$USERNAME/.bashrc

ENV JAX_ENABLE_X64=1
WORKDIR $USER_WORKSPACE
