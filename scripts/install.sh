#!/bin/bash

# install apt packages
sudo apt-get update \
  && sudo apt-get install -y \
    curl \
    build-essential \
    nmap \
    iputils-ping \
    git \
    net-tools \
    iptables \
    alsa-utils \
  && sudo apt-get autoremove -y

# install docker
#
# the containers are launched with docker compose, which ships with the
# convenience script's docker-compose-plugin
curl https://get.docker.com | sh \
  && sudo systemctl enable docker \
  && sudo systemctl start docker

# add your user to the `docker` group
#
# log out and back in (or run `newgrp docker`) for this to take effect
sudo usermod -aG docker $USER
newgrp docker

export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS=$REPO_ROOT/scripts
export SERVICES=$REPO_ROOT/services

# setup the utility aliases
#
# `nat` takes the wlan and eth interfaces as arguments (see `nat -h`) and
# `topside` manages the docker compose stack (see `topside -h`)
add_alias() {
  local name="$1"
  local command="$2"

  if grep -Fxq "alias $name='$command'" ~/.bashrc; then
    echo "[INFO] Alias '$name' already exists in ~/.bashrc"
  else
    echo "alias $name='$command'" >> ~/.bashrc
    echo "[INFO] Alias '$name' added to ~/.bashrc"
  fi
}

chmod +x $SCRIPTS/nat.sh $SCRIPTS/topside.sh \
  && add_alias "nat" "$SCRIPTS/nat.sh wlp62s0 enp61s0" \
  && add_alias "topside" "$SCRIPTS/topside.sh" \
  && source ~/.bashrc

# setup the topside systemd service
#
# this runs by default so that the stack doesn't need to be launched manually
# after the system boots
#
# the repository path is baked into the unit file at install time, so re-run
# this script if the repository is ever moved
sed "s|__REPO_ROOT__|$REPO_ROOT|g" $SERVICES/topside.service \
  | sudo tee /etc/systemd/system/topside.service > /dev/null \
  && sudo systemctl daemon-reload \
  && sudo systemctl enable topside.service \
  && sudo systemctl start topside.service
