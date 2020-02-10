# Configuration Docs

## For free5GC Stage 1

### Root

| Field                 | Object        | Description                                                                                                                         |
|-----------------------|---------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `global`              | Global        | Helm global values                                                                                                                  |
| `amf`                 | Amf           | AMF values                                                                                                                          |
| `hss`                 | IpAddr        | HSS IP address. This value should be same as `.global.freediameter.hss`                                                             |
| `smf`                 | IpAddr        | SMF IP address. This value should be same as `.global.freediameter.smf`                                                             |
| `pcrf`                | IpAddr        | PCRF IP address. This value should be same as `.global.freediameter.pcrf`                                                           |
| `upf`                 | Upf           | UPF values                                                                                                                          |
| `bandwidthManagement` | Boolean       | Flag to enable bandwidth management in Mininet and ONOS. Flag `.global.enableMininet` should be enabled if this flag is set to ture |
| `topo`                | String        | Topology script for Mininet                                                                                                         |
| `env`                 | OnosEnv array | Array of environment variables for ONOS                                                                                             |

### Global

| Field           | Object       | Description                                                                                                                 |
|-----------------|--------------|-----------------------------------------------------------------------------------------------------------------------------|
| `freediameter`  | Freediameter | FreeDiameter configurations for free5GC                                                                                     |
| `enableMininet` | Boolean      | Flag to enable Mininet pod. This flag should be negative to flag `.global.enableSriov`                                      |
| `enableSriov`   | Boolean      | Flag to enable SR-IOV on AMF's and UPF's interfaces to eNodeB. This flag should be negative to flag `.global.enableMininet` |
| `mnEnbBridge`   | IpamConf     | IPAM configuration of type host-local for bridge between Mininet and eNodeB                                                 |
| `mnUpfBridge`   | IpamConf     | IPAM configuration of type host-local for bridge between Mininet and UPF                                                    |

### Amf

| Field  | Object | Description                    |
|--------|--------|--------------------------------|
| `http` | IpAddr | IP address of AMF HTTP channel |
| `s1ap` | IpAddr | IP address of AMF S1AP channel |

### Upf

| Field       | Object | Description                     |
|-------------|--------|---------------------------------|
| `pfcp`      | IpAddr | IP address of UPF PFCP channel  |
| `gtpu`      | IpAddr | IP address of UPF GTP-U channel |
| `enbSubnet` | String | IP subnet of eNodeB             |

### OnosEnv

| Field   | Object | Description                |
|---------|--------|----------------------------|
| `name`  | String | Environment variable name  |
| `value` | String | Environment variable value |

### Freediameter

| Field  | Object | Description                                                                      |
|--------|--------|----------------------------------------------------------------------------------|
| `amf`  | IpAddr | IP address of AMF FreeDiameter channel. This value should be same as `.amf.http` |
| `hss`  | IpAddr | IP address of HSS FreeDiameter channel. This value should be same as `.hss`      |
| `smf`  | IpAddr | IP address of SMF FreeDiameter channel. This value should be same as `.smf`      |
| `pcrf` | IpAddr | IP address of PCRF FreeDiameter channel. This value should be same as `.pcrf`    |

### IpamConf

See [containernetworking/plugins#plugins/ipam/host-local](https://github.com/containernetworking/plugins/blob/master/plugins/ipam/host-local)

### IpAddr

| Field  | Object | Description |
|--------|--------|-------------|
| `addr` | String | IP address  |
