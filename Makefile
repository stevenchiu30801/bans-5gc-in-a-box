SHELL	:= /bin/bash
MAKEDIR	:= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD	?= $(MAKEDIR)/tmp
M		?= $(BUILD)/milestones
R		?= /tmp
DEPLOY	?= $(MAKEDIR)/deploy
HELMDIR	?= $(MAKEDIR)/helm-charts

# 18.06.2~ce~3-0~ubuntu in Kubernetes document
DOCKER_VERSION	?= 18.06.2

K8S_VERSION		?= 1.16.2

CALICO_VERSION		?= 3.8
CALICOCTL_VERSION	?= 3.8.5

HELM_VERSION	?= 3.0.0
HELM_PLATFORM	?= linux-amd64

GO_VERSION	?= 1.13.5

BANSVALUES	?= $(HELMDIR)/configs/bans-5gc.yaml
HELM_ARGS	?= --install --wait --timeout 6m -f $(BANSVALUES)

# ONOS APPs
BMV2_DRIVER_APP	?= org.onosproject.drivers.bmv2
BW_MGNT_APP		?= org.onosproject.bandwidth-management

SLICE_CONFIG	?= $(DEPLOY)/slice.json

# Targets
bans-5gc: free5gc

bans-5gc-ovs: BANSVALUES := $(HELMDIR)/configs/bans-5gc-ovs.yaml
bans-5gc-ovs: $(M)/cluster-setup $(M)/multus-init onos mininet free5gc

bans-5gc-bmv2: BANSVALUES := $(HELMDIR)/configs/bans-5gc-bmv2.yaml
bans-5gc-bmv2: $(M)/cluster-setup $(M)/multus-init bans-network-setup free5gc check-connect onos-bw-mgnt-app onos-bw-slice

cluster: $(M)/kubeadm /usr/local/bin/helm
install: /usr/bin/kubeadm /usr/local/bin/helm
preference: $(M)/preference

sriov-setup: $(M)/sriov-init $(M)/multus-init

$(M)/setup:
	sudo apt update
	sudo apt install -y curl httpie jq
	sudo $(MAKEDIR)/scripts/portcheck.sh
	sudo swapoff -a
	# To remain swap disabled after reboot
	# sudo sed -i '/ swap / s/^\(.*\)$$/#\1/g' /etc/fstab
	sudo modprobe openvswitch
	mkdir -p $(M)
	touch $@

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
/usr/bin/docker:
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce=${DOCKER_VERSION}*
	# Currently, systemd would report error in kubelet logs on both ubuntu Xenial and Bionic
	# Please refer to https://github.com/kubernetes/kubernetes/issues/76531
	# echo -e "{\n\
	# 	\"exec-opts\": [\"native.cgroupdriver=systemd\"],\n\
	# 	\"log-driver\": \"json-file\",\n\
	# 	\"log-opts\": {\n\
	# 		\"max-size\": \"100m\"\n\
	# 	},\n\
	# 	\"storage-driver\": \"overlay2\"\n\
	# }" | sudo tee /etc/docker/daemon.json
	# sudo mkdir -p /etc/systemd/system/docker.service.d
	# sudo systemctl daemon-reload
	# sudo systemctl restart docker
	# https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
	sudo groupadd docker
	sudo usermod -aG docker $$USER
	@echo "Please log out and log back in so that your group membership is re-evaluated"

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
/usr/bin/kubeadm: | /usr/bin/docker
	sudo apt-get update
	sudo apt-get install -y apt-transport-https curl
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubelet=${K8S_VERSION}-* kubeadm=${K8S_VERSION}-* kubectl=${K8S_VERSION}-*
	sudo apt-mark hold kubelet kubeadm kubectl
	# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-control-plane-node
	# When using Docker, kubeadm will automatically detect the cgroup driver for the kubelet
	# echo "KUBELET_EXTRA_ARGS=--cgroup-driver=systemd" | sudo tee /etc/default/kubelet
	# sudo systemctl daemon-reload
	# sudo systemctl restart kubelet

# https://helm.sh/docs/intro/install/#from-the-binary-releases
/usr/local/bin/helm:
	curl -L -o ${BUILD}/helm.tgz https://get.helm.sh/helm-v${HELM_VERSION}-${HELM_PLATFORM}.tar.gz
	cd ${BUILD}; tar -zxvf helm.tgz
	sudo mv ${BUILD}/${HELM_PLATFORM}/helm $@
	sudo chmod a+x $@
	rm -r ${BUILD}/helm.tgz ${BUILD}/${HELM_PLATFORM}

# https://docs.projectcalico.org/v3.10/getting-started/calicoctl/install
/usr/local/bin/calicoctl:
	curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v${CALICOCTL_VERSION}/calicoctl
	sudo chmod +x calicoctl
	sudo chown root:root calicoctl
	sudo mv calicoctl $@
	# https://docs.projectcalico.org/v3.10/getting-started/calicoctl/configure/
	sudo mkdir -p /etc/calico
	echo -e "apiVersion: projectcalico.org/v3\n\
	kind: CalicoAPIConfig\n\
	metadata:\n\
	spec:\n\
	  datastoreType: \"kubernetes\"\n\
	  kubeconfig: \"/etc/kubernetes/admin.conf\"" | sudo tee /etc/calico/calicoctl.cfg

# https://golang.org/doc/install#install
/usr/local/go:
	curl -O -L https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
	echo -e '\nexport PATH=$$PATH:/usr/local/go/bin' >> $(HOME)/.profile
	rm go${GO_VERSION}.linux-amd64.tar.gz
	@echo -e "Please reload your shell or source $$HOME/.profile to apply the changes:\n\
		source $$HOME/.profile"

.PHONY: cni-plugins-update

# https://github.com/containernetworking/plugins
cni-plugins-update: | /usr/local/go
	-git clone https://github.com/containernetworking/plugins $(R)/plugins
	cd $(R)/plugins; git pull
	export PATH=$$PATH:/usr/local/go/bin; cd $(R)/plugins; ./build_linux.sh
	mkdir -p /opt/cni/bin
	sudo cp $(R)/plugins/bin/* /opt/cni/bin

# https://github.com/intel/sriov-cni.git
/opt/cni/bin/sriov: | /usr/local/go
	-git clone https://github.com/intel/sriov-cni.git $(R)/sriov-cni
	export PATH=$$PATH:/usr/local/go/bin; cd $(R)/sriov-cni; make
	mkdir -p /opt/cni/bin
	sudo cp $(R)/sriov-cni/build/sriov $@

# https://github.com/intel/sriov-network-device-plugin
$(R)/sriov-network-device-plugin/build/sriovdp: | /usr/local/go
	-git clone https://github.com/intel/sriov-network-device-plugin.git $(R)/sriov-network-device-plugin
	export PATH=$$PATH:/usr/local/go/bin; cd $(R)/sriov-network-device-plugin; make && make image

$(M)/preference: | /usr/bin/kubeadm /usr/local/bin/helm
	# https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion
	sudo apt-get install bash-completion
	kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
	# Avoid error on completion of filename following helm repository field
	# E.g. helm install mychart ./mychart
	#                             ^
	#                             Would pop error related to tail command when hit tab for completion
	helm completion bash | sed "s/tail +2/tail +2 2>\/dev\/null/g" | sudo tee /etc/bash_completion.d/helm
	touch $@
	@echo -e "Please reload your shell or source the bash-completion script to make autocompletion work:\n\
	    source /usr/share/bash-completion/bash_completion"

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
$(M)/kubeadm: | $(M)/setup /usr/bin/kubeadm
	# https://coredns.io/plugins/loop/#troubleshooting
	# DNS forwarding loop is encoutered
	echo "nameserver 8.8.8.8" | tee /tmp/resolv.conf
	# sudo kubeadm init --pod-network-cidr=192.168.0.0/16
	sudo kubeadm init --config=$(DEPLOY)/kubeadm-config.yaml
	mkdir -p $(HOME)/.kube
	sudo cp -f /etc/kubernetes/admin.conf $(HOME)/.kube/config
	sudo chown $(shell id -u):$(shell id -g) $(HOME)/.kube/config
	# https://docs.projectcalico.org/v3.10/getting-started/kubernetes/installation/calico
	# To use a pod CIDR different from 192.168.0.0/16, please replace it in calico.yaml with your own
	kubectl apply -f https://docs.projectcalico.org/v${CALICO_VERSION}/manifests/calico.yaml
	kubectl taint nodes --all node-role.kubernetes.io/master-
	touch $@
	@echo "Kubernetes control plane node created!"

# https://github.com/intel/multus-cni/blob/master/doc/quickstart.md
$(M)/multus-init: | $(M)/kubeadm
	# -git clone https://github.com/intel/multus-cni.git $(R)/multus
	# cat $(R)/multus/images/multus-daemonset.yml | kubectl apply -f
	kubectl apply -f https://raw.githubusercontent.com/intel/multus-cni/master/images/multus-daemonset.yml
	touch $@

# https://github.com/intel/sriov-network-device-plugin
$(M)/sriov-init: | $(M)/kubeadm /opt/cni/bin/sriov $(R)/sriov-network-device-plugin/build/sriovdp
	kubectl apply -f $(DEPLOY)/sriov-configmap.yaml
	kubectl apply -f $(R)/sriov-network-device-plugin/deployments/k8s-v1.16/sriovdp-daemonset.yaml
	touch $@

$(M)/cluster-setup: | $(M)/kubeadm /usr/local/bin/helm
	touch $@

/nfsshare:
	sudo apt update
	sudo apt install -y nfs-kernel-server
	echo "/nfsshare   localhost(rw,sync,no_root_squash)" | sudo tee /etc/exports
	sudo mkdir $@
	sudo exportfs -r
	# Check if /etc/exports is properly loaded
	# showmount -e localhost

.PHONY: bans-network-setup check-onos check-connect onos-bw-mgnt-app onos-bw-slice

bans-network-setup: $(M)/kubeadm $(M)/multus-init onos check-onos mininet

check-onos:
	@until http -a onos:rocks --ignore-stdin --check-status GET http://127.0.0.1:30181/onos/v1/applications/org.onosproject.drivers.bmv2 2>&- | jq '.state' 2>&- | grep 'ACTIVE' >/dev/null; \
	do \
		echo "Waiting for ONOS to be ready"; \
		sleep 5; \
	done

check-connect:
	scripts/check_connect.sh

onos-bw-mgnt-app:
	helm upgrade $(HELM_ARGS) --set appCommand=activate --set appName=$(BW_MGNT_APP) activate-bw-mgnt $(HELMDIR)/onos-app
	@until kubectl get job -o=jsonpath='{.items[?(@.status.succeeded==1)].metadata.name}' | grep 'activate-bw-mgnt-onos-app' >/dev/null; \
	do \
		echo "Waiting for bandwidth management application to be activated"; \
		sleep 3; \
	done
	@until ! http -a onos:rocks GET http://127.0.0.1:30181/onos/v1/flows/device:bmv2:s1 2>&- | jq '.flows[].state' | grep 'PENDING_ADD' >/dev/null; \
	do \
		echo "Waiting for flows of bandwidth management to be added"; \
		sleep 5; \
	done

onos-bw-slice:
	curl -u onos:rocks -X POST -H "Content-Type:application/json" -d @$(SLICE_CONFIG) http://127.0.0.1:30181/onos/bandwidth-management/slices
	@echo -e "\nSuccessfully add slice!"

.PHONY: onos mininet mongo free5gc

onos: $(M)/cluster-setup
	helm upgrade $(HELM_ARGS) onos $(HELMDIR)/onos

mininet: $(M)/cluster-setup $(M)/multus-init
	helm upgrade $(HELM_ARGS) mininet $(HELMDIR)/mininet

mongo: $(M)/cluster-setup /nfsshare
	helm upgrade $(HELM_ARGS) mongo $(HELMDIR)/mongo

# https://www.free5gc.org/cluster
free5gc: $(M)/cluster-setup mongo
	helm upgrade $(HELM_ARGS) free5gc $(HELMDIR)/free5gc
	@echo "Deployment completed!"

.PHONY: reset-free5gc

reset-bans5gc:
	-helm uninstall activate-bw-mgnt
	-helm uninstall onos
	-helm uninstall mininet
	-helm uninstall free5gc
	sleep 1
	# https://github.com/kubernetes/kubernetes/issues/49387
	# Currently there is no way to filter pod status `Terminating`
	@until ! kubectl get pods | grep 'Terminating' >/dev/null; \
	do \
		echo "Waiting for pods to be terminated"; \
		sleep 5; \
	done
	sudo rm -rf /var/lib/cni/networks/mn*
	-for br in /sys/class/net/mn*; do sudo ip link delete `basename $$br` type bridge; done
	@echo "Reset completed!"

.PHONY: reset-kubeadm

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down
reset-kubeadm:
	-sudo kubeadm reset -f
	sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
	sudo rm -rf /var/lib/cni/networks/mn*
	-for br in /sys/class/net/mn*; do sudo ip link delete `basename $$br` type bridge; done
	rm -f $(M)/setup $(M)/kubeadm $(M)/multus-init $(M)/sriov-init $(M)/cluster-setup

force-reset:
	-sudo killall kubelet etcd kube-apiserver kube-controller-manager kube-scheduler
	sudo rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /etc/cni
