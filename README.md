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

### Setup

The setup assumes the eNodeB is directly connected to the server. Please modify eNodeB network configuration to work with your network environment.

#### Without SR-IOV

```ShellSession
# On Kubernetes node

# Pre-install
sudo apt install -y make

# Configure network environment
sudo ip address add 192.168.3.2/24 dev ${ENODEB_INTF}
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
```

Configure eNodeB settings
- IP address in subnet 192.168.3.0/24 (excluding ${ENODEB_INTF})
- Gateway/Router 192.168.3.2
- MME/AMF IP 192.168.2.2

NOTE 1: ${ENODEB_INTF} is server's interface connecting to eNodeB.

NOTE 2: For [deploying 5GC only](#deploying-5gc-only), it should be fine to set your desired address and subnet on both eNodeB and Kubernetes node interface connecting to eNodeB. Simply make sure packets can be correctly forwarded between two devices.

NOTE 3: For deploying 5GC [with SDN-based transport](#deploying-5gc-with-sdn-based-transport) and [with BANS](#deploying-5gc-with-bans), ${ENODEB_INTF} should be any available address under subnet 192.168.3.0/24 by default. See [Customizing Configuration](#customizing-configuration) section to customize the subnet in deployment.

NOTE 4: For deploying 5GC [with SDN-based transport](#deploying-5gc-with-sdn-based-transport) and [with BANS](#deploying-5gc-with-bans), it's important to make sure the index of network interface connecting to the Internet is smaller than the one connecting to eNodeB.

#### With SR-IOV

```ShellSession
# On Kubernetes node

# Pre-install
sudo apt install -y make
```

Configure eNodeB settings
- IP address in subnet 192.168.3.0/24 (excluding 192.168.3.2 and 192.168.3.6)
- MME/AMF IP 192.168.3.2

NOTE 1: 192.168.3.2 and 192.168.3.6 are AMF's and UPF's IP address respectively by default. See [Customizing Configuration](#customizing-configuration) section to customize two IP addresses.

### Deploying 5GC Only

```ShellSession
# Deploy
make

# or
make bans-5gc
```

### Deploying 5GC with SDN-based Transport

A OvS-based Mininet pod is placed between eNodeB and UPF pod.

Open vSwitches are controlled by [ONOS](https://github.com/opennetworkinglab/onos).

```ShellSession
# Deploy
make bans-5gc-ovs
```

### Deploying 5GC with BANS

```ShellSession
# Deploy
make bans-5gc-bmv2

# Override default slice configuration
SLICE_CONFIG=/path/to/file make bans-5gc-bmv2

# Add new onos slice on existing deployment
SLICE_CONFIG=/path/to/file make onos-bw-slice
```

Example slice configuration is placed at `deploy/slice.json`.

### Deploying 5GC Only with SR-IOV

```ShellSession
# Deploy
# The argument `SRIOV_INTF` is required for server setup and creating SR-IOV resources
SRIOV_INTF=devicename make bans-5gc-sriov
```

NOTE 1: The *make* script performs server setup for SR-IOV, such as loading device's kernel module and creating required virtual functions, which is experimental and only be tested with Intel Ethernet adapters. Manually configure your server for SR-IOV devices if *make* fails at target *sriov-server-setup*.

### Customizing Configuration

```ShellSession
# Customize configuration
BANSVALUES=/path/to/file make [target]
```

Default configuration files for deployment locate in `helm-charts/configs/<target>.yaml`.

See `helm-charts/configs/README.md` for more informations.

### User Interface

Web UI to subscriber database is running on port 30300. Default username and password are *admin* and *1423*.

ONOS GUI is exposed on port 30181. Default username and password are *onos* and *rocks*.

## Troubleshooting

### Unreachable UPF

**Description**

Especially in deploying 5GC [with SDN-based transport](#deploying-5gc-with-sdn-based-transport) and [with BANS](#deploying-5gc-with-bans), ARP cache of UPF pod is incompleted on the Kubernetes node.

**Root Cause**

Calico CNI exploits routing table and iptables infrastructure for communication of workloads, and Kernel sets source IP address of ARP requests for workloads to address of the first available network interface in the order of interface index numbers, except loopback addresses.

The problem takes place when network interface connecting to eNodeB has the smallest index number among all interfaces with available addresses, which means it takes priority over others on the decision of source address of ARP requests. Since UPF pod has a route to direct traffic with the destination of eNodeB to Mininet in such two deployments, replies to ARP requests from UPF cannot be correctly sent back to Kubernetes node.

**Workaround**

Add a dummy address, other than loopback addresses, on the loopback interface to force Kernel set source address of ARP requests to it, since loopback interface has the smallest index number.

## Dockerfile

Please see [stevenchiu30801/bans-5gc-images](https://github.com/stevenchiu30801/bans-5gc-images.git).

## Reference
[1] [P4-Enabled Bandwidth Management](https://ieeexplore.ieee.org/abstract/document/8892909)\
[2] [opencord/automation-tools](https://github.com/opencord/automation-tools)
