#!/bin/bash

usage() {
    echo "***Experimental script for SR-IOV configuration***"
    echo "Configure virtual functions on SR-IOV interface"
    echo ""
    echo "Usage: ./sriov_config.sh SRIOV-INTF NUM_VF"
    echo "Arguments:"
    echo "    SRIOV_INTF        Interface to be enabled SR-IOV"
    echo "    NUM_VF            Number of VFs to be created"
}

if [[ $# -eq 2 ]]; then
    if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
        usage
        exit 0
    fi

    # Check if input NUM_VF is an integer
    if ! [[ $2 =~ ^[0-9]+$ ]]; then
        usage
        exit 1
    fi
else
    usage
    exit 1
fi

# Check if number of existing VFs meets requested number
EXISTING_VF=$( ip link show $1 | grep -c vf )
if [[ ${EXISTING_VF} -eq $2 ]]; then
    echo "Number of existing VFs is exactly $2"
    exit 0
fi

# Check if IOMMU support for Linux kernel is enable
if ! dmesg | grep 'DMAR: IOMMU enabled' >/dev/null; then
    echo -e "Please enable IOMMU support for Linux kernel\n\
        1. Append 'intel_iommu=on' to the 'GRUM_CMDLINE_LINUX' entry in /etc/default/grub\n\
        2. Update grub with command 'update-grub'\n\
        3. Reboot for IOMMU change to take effect"
    exit 1
fi

# Check the driver used by the interface
DRIVER=$( ethtool -i $1 | awk '$1=="driver:" {print $2}' )

# Check if driver is included in Linux kernel
if ! find /lib/modules/$(uname -r) -type f -name '*.ko' | grep /${DRIVER}.ko >/dev/null; then
    echo "PF driver '${DRIVER}' is not provided in kernel"
    echo "Please install the driver '${DRIVER}'"
    exit 1
elif ! find /lib/modules/$(uname -r) -type f -name '*.ko' | grep /${DRIVER}vf.ko >/dev/null; then
    echo "VF driver '${DRIVER}vf' is not provided in kernel"
    echo "Please install the driver '${DRIVER}vf'"
    exit 1
fi

# Load device's kernel module
modprobe ${DRIVER}

# Check if the requested number of VFs exceeds the maximum number of supported VFs
TOTAL_VF=$( cat /sys/class/net/$1/device/sriov_totalvfs )
if [[ $2 -gt ${TOTAL_VF} ]]; then
    echo "Number of VFs should not exceed the maximum number of VFs supported by the adapter '$1'"
    echo "Maximum number: ${TOTAL_VF}"
    exit 1
fi

# Create VFs
echo $2 | sudo tee /sys/class/net/$1/device/sriov_numvfs >/dev/null
