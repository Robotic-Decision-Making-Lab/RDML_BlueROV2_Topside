# Topside Software

This repository hosts the necessary software, configurations, and documentation
for deploying the Robotic Decision Making Lab's (RDML) topside system with the
BlueROV2.

## Installation

Clone the repository and run the install script to install the system
dependencies (including Docker) and configure the utility aliases:

```bash
git clone git@github.com:Robotic-Decision-Making-Lab/RDML_BlueROV2_Topside.git
cd RDML_BlueROV2_Topside && ./scripts/install.sh
```

Log out and back in afterward so that the `docker` group membership and the new
aliases take effect.

## Usage

The topside stack, including the system monitor and joystick interface, is
orchestrated by Docker Compose. These services are loaded automatically at
boot. To check the status of the service, run

```bash
# check the service status
systemctl status topside.service
docker compose -f docker/docker-compose.yml ps

# view the service logs
docker compose -f docker/docker-compose.yml logs -f topside
```

### Visualization

RViz can be launched from a container using the `rviz` alias

```bash
rviz
```

which loads the [RViz configuration file](ros/topside_description/config/topside.rviz)
by default.

## Networking

The topside computer serves as the root of the BlueROV network and provides
internet access via NAT.

### Assign a static IP

Set the Ethernet interface (connected to the BlueROV network) to `192.168.2.1`.

### Enable internet masqurading

Internet forwarding from the topside system to the BlueROV2 is enabled using
network address translation (NAT), which configures the topside device as a
network gateway. This interface is exposed through `scripts/nat.sh`:

```bash
# run using
nat <wlan_interface> <eth_interface>

# append the -h flag for further details
nat -h
```

### Configuring SSH key authentication for the local network

1. Generate an SSH key for the local network

    ```bash
    ssh-keygen -t ed25519 -C "BlueROV network key"
    ```

2. Copy the public key to each device in the subsystem

    ```bash
    ssh-copy-id -i ~/.ssh/<ssh key>.pub user@device_ip
    ```

3. Manage the SSH key identities in `~/.ssh/config` (optional)

    ```bash
    Host device1
        HostName <ip-address>
        User <username>
        IdentityFile <path-to-ssh-key-file>
    ```

## Citation

This repository has been used in the following papers:

```bibtex
@article{palmer2026stochastic,
  title         = {{Stochastic Physics-Informed Neural Networks on Lie Groups for Learning Underwater Vehicle Dynamics}},
  author        = {Palmer, Evan F. and Hatton, Ross L. and Hollinger, Geoffrey A.},
  journal       = {arXiv preprint arXiv:2608.08356},
  year          = {2026},
  eprint        = {https://doi.org/10.48550/arXiv.2608.08356},
  archivePrefix = {arXiv},
  primaryClass  = {cs.RO},
}
```

## License

RDML_BlueROV2_Topside is released under the [MIT License](LICENSE).
