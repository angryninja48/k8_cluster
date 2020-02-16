#kubectl create ns rook-ceph
#kubectl create -f https://raw.githubusercontent.com/rook/rook/release-1.0/cluster/examples/kubernetes/ceph/common.yaml
#kubectl create -f https://raw.githubusercontent.com/rook/rook/release-1.0/cluster/examples/kubernetes/ceph/operator.yaml

helm repo add rook-release https://charts.rook.io/release

#Helm2
helm install --name rook-operator \
  --namespace rook-ceph \
  --set image.tag=v1.1.8-4.g0a24c16 \
  --set csi.kubeletDirPath=/opt/rke/var/lib/kubelet \
  --set enableFlexDriver=true \
  rook-release/rook-ceph

#Helm3
kubectl create ns rook-ceph
helm install rook-operator --namespace rook-ceph \
  --set image.tag=v1.1.8-4.g0a24c16 \
  rook-master/rook-ceph



# Provision cluster
kubectl create -f provision/storage/rook/cluster.yaml

# Provision storage block
# Create storage class
kubectl create -f provision/storage/rook/storageclass.yaml

# Provision toolbox
kubectl create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/toolbox.yaml


###### Removal #######
# Delete /var/lib/rook
# Format disk fdisk /dev/sda -w and enter
# kubectl delete -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/toolbox.yaml
# kubectl delete -f provision/storage/rook/storageclass.yaml
# kubectl delete -f provision/storage/rook/cluster.yaml
#
# helm uninstall rook-operator -n rook-ceph
# kubectl delete pods,svc,deployment,rs -n rook-ceph --all
