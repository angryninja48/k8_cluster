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
helm upgrade --install influxdb --namespace monitoring \
-f ./values.yaml \
--set setDefaultUser.user.password=$INFLUXDB_PW \
influxdata/influxdb
