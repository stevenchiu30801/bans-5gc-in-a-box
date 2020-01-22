#!/bin/bash

MN1_ADDR=$( ip -4 address show mn1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" )
UPF_POD=$( kubectl get pod -l app.kubernetes.io/instance=free5gc -l app.kubernetes.io/name=upf -o jsonpath='{.items[0].metadata.name}' )

kubectl exec $UPF_POD -- ping -c 3 $MN1_ADDR
