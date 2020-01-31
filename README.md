# BANS-5GC-in-a-Box

Bandwidth-Allocated Network Slicing on 5G Core

## Introduction

BANS-5GC enables network slicing with specific bandwidth allocation policies on 5G core network by utilizing programmable data plane on transport network.

The 5GC uses [free5GC](https://www.free5gc.org/), an open-source 5G core network.

The programmable data plane application for bandwidth management uses a research from 2019 20th APNOMS[1].

All functions are containerized and deployed on [Kubernetes](https://github.com/kubernetes/kubernetes).

## Supported Components
- Docker v18.06.2
- Kubernetes v1.16.2
- Calico v3.8
- Helm 3.0.0
- free5GC Stage 1

## Hardware Requirement
- CPU 2 cores
- RAM 8GB
- NIC 2 cards (connecting to eNodeB and the Internet)

## Usage

### Deploy 5GC with SDN-based Transport

```ShellSession
# On Kubernetes node

# Pre-install
sudo apt install -y make

# Configure network environment
sudo ifconfig ${ENODEB_INTF} 192.168.3.2
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'


# Deploy
make free5gc
```

Configure eNodeB settings
- IP address in subnet 192.168.3.0/24 (excluding 192.168.3.2)
- Gateway/Router 192.168.3.2
- MME/AMF IP 192.168.2.2

## Dockerfile

The Dockerfile is referred to [open5gs/open5gs](https://github.com/open5gs/open5gs/tree/master/docker)

## Reference
[1] [P4-Enabled Bandwidth Management](https://ieeexplore.ieee.org/abstract/document/8892909)\
[2] [opencord/automation-tools](https://github.com/opencord/automation-tools)
