#!/bin/bash
set -e
set -o pipefail

# Import ENV Vars
source kube.env

# Provision kubernetes
#rke up

# Not needed in helm3
# Install tiller
# kubectl -n kube-system create serviceaccount tiller
# kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
# helm init --service-account tiller

#Wait for tiller to be deployed
# sleep 30

# Install metallb
#kubectl create ns metallb
#kubectl apply -f metallb-configmap.yaml
helm install --name metallb --namespace metallb -f helm/metallb/values.yaml stable/metallb

# install ingress controller
#kubectl create ns ingress-system
helm install --name nginx-ingress --namespace ingress -f helm/ingress/values.yaml stable/nginx-ingress

# Install cert-manager - Change DNS as it needs to resolve external names to verify. Port 80 needs to be open as well
# Cert-manager creds
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm install --name cert-manager --namespace cert-manager --version v0.12.0 -f helm/certmanager/values.yaml jetstack/cert-manager

#Wait for cert-manager
sleep 30

# Generate secret for Cloudflare DNS challenge
kubectl create secret generic cloudflare-api-key --from-literal=api-key=$CLOUDFLARE_API_KEY -n cert-manager
# Install cert issuer (DNS)
kubectl apply -f apps/certmanager/issuer-dns.yaml
# Can use HTTP to validate if need be however requires port 80 to be opened and accessable from the internet
# kubectl apply -f apps/certmanager/issuer-http.yaml
# Test if needed:
# kubectl apply -f helm/certmanager/test-shim.yaml

##########
# Storage - Longhorn
##########
# Pre-req for rancheros
# https://github.com/longhorn/longhorn/blob/master/docs/csi-config.md
# sudo ros console switch ubuntu
# sudo apt update
# sudo apt install -y open-iscsi
# Open config file /etc/iscsi/iscsid.conf
# Comment iscsid.startup = /bin/systemctl start iscsid.socket
# Uncomment iscsid.startup = /sbin/iscsid
#
###### mount drives i.e. /dev/sda -> /storage

helm install provision/storage/longhorn --name longhorn --namespace longhorn-system
# Need to configure via GUI - need to look into this


# Add rancher repo
# helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# #helm install --name rancher --namespace cattle-system --set hostname=rancher3.k8s.angrynet.ninja --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=jonbaker85@gmail.com rancher-stable/rancher
# helm install --name rancher --namespace rancher -f helm/rancher2/values.yaml rancher-stable/rancher

# Add NFS storage class
helm install --name nfs-storage --namespace nfs-storage -f helm/nfs/values.yaml stable/nfs-client-provisioner
