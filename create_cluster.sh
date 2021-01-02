#!/bin/bash
set -e
set -o pipefail

# Import ENV Vars
source kube.env

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

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
# kubectl create ns metallb
#kubectl apply -f metallb-configmap.yaml
helm install \
    metallb bitnami/metallb \
    -f apps/metallb/values.yml \
    --create-namespace \
    --namespace ingress 

# install ingress controller
#kubectl create ns ingress-system
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo add stable https://charts.helm.sh/stable
# helm repo update
# helm install nginx-internal-ingress --namespace ingress -f apps/nginx-ingress/internal/values.yaml ingress-nginx/ingress-nginx --create-namespace
# helm install nginx-external-ingress --namespace ingress -f apps/nginx-ingress/external/values.yaml ingress-nginx/ingress-nginx --create-namespace

# Install cert-manager - Change DNS as it needs to resolve external names to verify. Port 80 needs to be open as well
# Cert-manager creds
# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.crds.yaml
# helm install cert-manager --namespace cert-manager --version v1.1.0 -f apps/certmanager/values.yaml jetstack/cert-manager 

helm install \
    internal-ingress nginx-stable/nginx-ingress \
    -f apps/nginx-ingress/internal/values.yaml \
    --create-namespace \
    --namespace ingress 

helm install \
    external-ingress nginx-stable/nginx-ingress \
    -f apps/nginx-ingress/external/values.yaml \
    --create-namespace \
    --namespace ingress 


helm install \
  cert-manager jetstack/cert-manager \
#   -f apps/certmanager/values.yaml \
  --namespace cert-manager \
  --version v1.1.0 \
  --create-namespace \
  --set ingressShim.defaultIssuerName=letsencrypt-staging \
  --set ingressShim.defaultIssuerKind=ClusterIssuer \
  --set 'extraArgs={--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}' \
  --set installCRDs=true

#Wait for cert-manager
sleep 30

# Generate secret for Cloudflare DNS challenge
kubectl create secret generic cloudflare-api-key --from-literal=api-key=$CLOUDFLARE_API_KEY -n cert-manager
# Install cert issuer (DNS)
kubectl apply -f apps/certmanager/issuer-dns.yaml
# Can use HTTP to validate if need be however requires port 80 to be opened and accessable from the internet
# kubectl apply -f apps/certmanager/issuer-http.yaml
# Test if needed:
# kubectl apply -f apps/certmanager/test-shim.yaml

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

helm install \
    longhorn longhorn/longhorn \
    -f apps/certmanager/values.yaml \
    --namespace longhorn-system \
    --create-namespace

helm install \
    pihole charts/pihole \
    -f apps/pihole/values.yaml \
    --namespace pihole \
    --create-namespace


# Need to configure via GUI - need to look into this


# Add rancher repo
# helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# #helm install --name rancher --namespace cattle-system --set hostname=rancher3.k8s.angrynet.ninja --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=jonbaker85@gmail.com rancher-stable/rancher
# helm install --name rancher --namespace rancher -f helm/rancher2/values.yaml rancher-stable/rancher

# # Add NFS storage class
# helm install \
#     --name nfs-storage stable/nfs-client-provisioner \
#     -f helm/nfs/values.yaml \
#     --namespace nfs-storage \
#     --create-namespace

# K8's at home repo
helm repo add k8s-at-home https://k8s-at-home.com/charts/



helm template \
    home-assistant k8s-at-home/home-assistant \
    -f apps/home-assistant/values.yaml \
    --namespace hass \
    --create-namespace
