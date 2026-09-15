#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../docker/docker-compose.yml"
SERVICES=(topside teleop)

usage() {
  echo "Usage: $0 <command> [options]"
  echo "Commands:"
  echo "  up [-b|--build] [-d|--detach]: Launch the topside and teleop containers"
  echo "  down: Stop and remove the containers"
  echo "  logs [service]: Follow the container logs (all services by default)"
  echo "  shell [service]: Open a shell in a running container (teleop by default)"
  echo "Example: $0 up --build"
  exit 1
}

compose() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

up() {
  local flags=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b | --build)
        flags+=("--build")
        ;;
      -d | --detach)
        flags+=("--detach")
        ;;
      *)
        echo "[ERROR] Unknown option '$1'."
        usage
        ;;
    esac
    shift
  done

  echo "[INFO] Launching the ${SERVICES[*]} containers"
  compose up "${flags[@]}" "${SERVICES[@]}"
}

down() {
  echo "[INFO] Stopping the ${SERVICES[*]} containers"
  compose down
}

logs() {
  compose logs -f "$@"
}

shell() {
  local service="${1:-teleop}"

  echo "[INFO] Opening a shell in the $service container"
  compose exec "$service" bash
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ $# -lt 1 ]]; then
  echo "[ERROR] Invalid number of arguments."
  usage
fi

COMMAND="$1"
shift

case "$COMMAND" in
  up)
    up "$@"
    ;;
  down)
    down
    ;;
  logs)
    logs "$@"
    ;;
  shell)
    shell "$@"
    ;;
  *)
    echo "[ERROR] Unknown command '$COMMAND'."
    usage
    ;;
esac
