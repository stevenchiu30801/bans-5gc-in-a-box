# BANS-5GC-in-a-Box

Bandwidth-Allocated Network Slicing on 5G Core

## Introduction

BANS-5GC enables network slicing with specific bandwidth allocation policies on 5G core network by utilizing programmable data plane on transport network.

The 5GC uses free5GC[1], an open-source 5G core network.

The programmable data plane application for bandwidth management uses a research from 2019 20th APNOMS[2].

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

### Deploy 5GC Only

```
# On Kubernetes node

# Configure network environment
$ sudo ifconfig ${ENODEB_INTF} 192.168.3.2
$ sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'


# Deploy
$ make free5gc
```

Configure eNodeB settings
- IP address 192.168.3.3
- Gateway/Router 192.168.3.2
- MME/AMF IP 192.168.2.2 or 192.168.3.2

Note: In the case that MME/AMF IP is configured to 192.168.2.2, then control plane packets would take the interface of Kubernetes node as gateway and be forwarded with routing table. In another case, AMF pod would receive control plane packets by the Kubernetes service, `deploy/free5gc/amf/service.yaml`.

### Deploy BANS-5GC

(WIP)

## Dockerfile

The Dockerfile is referred to [open5gs/open5gs](https://github.com/open5gs/open5gs/tree/master/docker)

## Reference
[1] [free5GC](https://www.free5gc.org/)\
[2] [P4-Enabled Bandwidth Management](https://ieeexplore.ieee.org/abstract/document/8892909)\
[3] [opencord/automation-tools](https://github.com/opencord/automation-tools)
