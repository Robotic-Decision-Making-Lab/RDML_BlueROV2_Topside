ARG ROS_DISTRO=lyrical
FROM ros:${ROS_DISTRO}-ros-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update \
    && apt-get -q -y upgrade \
    && apt-get -q install --no-install-recommends -y \
    git \
    sudo \
    wget \
    curl \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -a -G dialout,audio $USERNAME

USER $USERNAME
ENV USER=$USERNAME

# install the text-to-speech system
RUN sudo apt-get -q update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get -q install --no-install-recommends -y \
    espeak-ng \
    libespeak1 \
    alsa-base \
    alsa-utils \
    libasound2-dev \
    acl \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# install python dependencies
ENV USER_WORKSPACE=/home/$USERNAME/ws_ros
ENV VIRTUAL_ENV=$USER_WORKSPACE/topside-venv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_LINK_MODE=copy

WORKDIR $USER_WORKSPACE
COPY --chown=$USERNAME:$USERNAME pyproject.toml uv.lock ./
RUN uv venv --system-site-packages $VIRTUAL_ENV \
    && uv sync --active --locked \
    && touch $VIRTUAL_ENV/COLCON_IGNORE

# the entrypoint doesn't source the venv, so expose its packages to ros2 launch
ENV PYTHONPATH=$VIRTUAL_ENV/lib/python3.14/site-packages

# install all ROS dependencies
COPY --chown=$USERNAME:$USERNAME ros/ /tmp/deps
RUN sudo apt-get -q update \
    && rosdep update \
    && rosdep install -y --from-paths /tmp/deps --ignore-src --rosdistro ${ROS_DISTRO} \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/* /tmp/deps

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "[ -f ~/ws_ros/install/setup.bash ] && source ~/ws_ros/install/setup.bash" >> /home/$USERNAME/.bashrc

COPY --chown=$USERNAME:$USERNAME docker/entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
