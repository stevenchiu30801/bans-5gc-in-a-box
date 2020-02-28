#!/bin/bash
# Fix UPF-SMF execution order in free5GC Stage 2

SMF_PODS=$( kubectl get pod -l app.kubernetes.io/instance=free5gc -l app.kubernetes.io/name=smf -o jsonpath='{.items[*].metadata.name}' )
IFS=' ' read -r -a smf_pod_list <<< "$SMF_PODS"

for smf_pod in "${smf_pod_list[@]}"
do
    if ! kubectl logs $smf_pod | grep 'HandlePfcpAssociationSetupResponse'; then
        kubectl delete pod $smf_pod
    fi
done
