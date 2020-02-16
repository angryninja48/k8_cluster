#!/usr/bin/env bash

set -e
set -o pipefail

if ! command -v kubectl > /dev/null; then
  echo "kubectl command not installed"
  exit 1
fi

echo -n "Purging helm chart... "
helm delete --purge gitlab

echo -n "Deleting namespace... "
kubectl delete -f _namespace.yml
