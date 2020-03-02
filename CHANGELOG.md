# Release-0.1

- Add 5GC deployment only using bare Kubernetes YAML files

# Release-0.2

- Add 5GC deployment with SDN-based transport with bare Kubernetes YAML files

# Release-1.0

- Add 5GC deployment with BANS
- Use Helm 3.0.0 to deploy Kubernetes objects

# Release-1.1

- Experimental server setup script for SR-IOV configuration
- Add 5GC deployment only with SR-IOV
- Add configuration documentation

# Release-1.2

- Rename free5GC Stage 1 target from bans-5gc to bans-5gcv1
- Add free5GC Stage 2
- Remove free5gc-stage-1 git submodule
- Extract Docker images to repository [stevenchiu30801/bans-5gc-images](https://github.com/stevenchiu30801/bans-5gc-images)

# Release-1.3

- Use unreleased version of free5GC for network slicing support
- Support network slicing in AMF, NSSF, SMF, UPF
- Use UPF address in NGAP-PDU Session Setup requests as GTP-U destination in RANSIM tests
- Set UE configuration with network slices in RANSIM tests
