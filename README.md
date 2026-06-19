# Topside Software

This repository hosts the necessary software, configurations, and documentation 
for deploying the topside system with the BlueROV 2 Heavy. Our topside system 
is primarily responsible for monitoring the BlueROV status, routing 
teleoperation commands, and logging.

## Installation

Install the topside software system by first cloning the project repository to
your topside device. Once cloned, the system can be used via the provided
[development container](https://containers.dev/) located in `.devcontainer`.

## Networking

The following section details the networking configurations for the topside
system.

<details>
  <summary>Network configuration</summary>

  The topside system should be assigned the static IP address:
  ```
  192.168.2.1
  ```
</details>

<details>
  <summary>Internet forwarding</summary>

  Internet forwarding from the topside system to the BlueROV is enabled using
  network address translation (NAT), which configures the topside device as a
  network gateway. This interface is exposed through `scripts/nat.sh`:
  ```bash
  ./nat.sh <wlan_interface> <eth_interface>
  ```
  To determine the interfaces used as arguments for `nat.sh`, run
  ```bash
  ip a
  ```
  The device names are generally unchanged across deployments, so you can assign
  an alias to the script using
  ```bash
  ./make_alias.sh "nat" <wlan_interface> <eth_interface>
  ```
  which assigns the alias to `nat`.
</details>

## License

RDML_BlueROV2_Topside is released under the MIT license.
