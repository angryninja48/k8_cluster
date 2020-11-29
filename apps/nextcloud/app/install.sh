#!/usr/bin/env bash

set -e
set -o pipefail

if ! command -v kubectl > /dev/null; then
  echo "kubectl command not installed"
  exit 1
fi


if ! command -v helm > /dev/null; then
  echo "helm command not installed"
  exit 1
fi

echo -n "Creating namespace... "
kubectl -f _namespace.yml create

echo -n "Installing helm chart... "
helm upgrade --install nextcloud --namespace nextcloud \
-f values.yaml \
--set nextcloud.username=$ROOT_USER \
--set nextcloud.password=$ROOT_PW \
--set mariadb.rootUser.password=$ROOT_DB_PW \
--set mariadb.db.user=$NEXTCLOUD_DB_USER \
--set mariadb.db.password=$NEXTCLOUD_DB_PW \
stable/nextcloud

# helm upgrade --recreate-pods nextcloud --namespace nextcloud \
# -f values.yaml \
# --set nextcloud.username=$ROOT_USER \
# --set nextcloud.password=$ROOT_PW \
# --set mariadb.rootUser.password=$ROOT_DB_PW \
# --set mariadb.db.user=$NEXTCLOUD_DB_USER \
# --set mariadb.db.password=$NEXTCLOUD_DB_PW \
# stable/nextcloud

