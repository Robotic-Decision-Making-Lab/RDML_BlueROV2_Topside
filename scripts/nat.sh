#!/bin/bash

usage() {
  echo "Usage: $0 <wlan_interface> <eth_interface>"
  echo "Arguments:"
  echo "  wlan_interface: The name of the WLAN interface (e.g., wlan0)"
  echo "  eth_interface: The name of the Ethernet interface (e.g., eth0)"
  exit 1
}

nat() {
  local wlan="$1"
  local eth="$2"

  echo "[INFO] Setting up NAT from $wlan to $eth"

  sudo sysctl -w net.ipv4.ip_forward=1
  sudo iptables -t nat -A POSTROUTING -o $wlan -j MASQUERADE
  sudo iptables -A FORWARD -i $eth -o $wlan -j ACCEPT
  sudo iptables -A FORWARD -i $wlan -o $eth -m state --state ESTABLISHED,RELATED -j ACCEPT

  echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-rdml-nat.conf > /dev/null
  sudo sysctl -p /etc/sysctl.d/99-rdml-nat.conf
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ $# -ne 2 ]]; then
  echo "[ERROR] Invalid number of arguments."
  usage
fi

WLAN="$1"
ETH="$2"

if [[ ! -d "/sys/class/net/$WLAN" ]]; then
  echo "[ERROR] Wireless interface '$WLAN' not found."
  exit 2
fi

if [[ ! -d "/sys/class/net/$ETH" ]]; then
  echo "[ERROR] Ethernet interface '$ETH' not found."
  exit 3
fi

nat "$WLAN" "$ETH"
