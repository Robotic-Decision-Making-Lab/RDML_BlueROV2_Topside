#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../docker/docker-compose.yml"

usage() {
  echo "Usage: $0"
  echo "Launch RViz in a container using the default topside configuration."
  echo "The configuration is ros/topside_description/config/topside.rviz"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ -z "$DISPLAY" ]]; then
  echo "[ERROR] DISPLAY is not set. RViz needs a local X session."
  exit 2
fi

# build an X authority file that the container can use
#
# rewriting the address family to 'ffff' makes the cookie match regardless of
# the hostname that the container sees. we generate this instead of mounting
# ~/.Xauthority because that file often doesn't exist under Wayland/GDM.
XAUTH=/tmp/.docker.xauth
touch "$XAUTH"
xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
chmod 644 "$XAUTH"

echo "[INFO] Launching RViz"

# `run --rm` keeps RViz in the foreground and leaves no container behind
TOPSIDE_XAUTH="$XAUTH" docker compose -f "$COMPOSE_FILE" run --rm rviz
