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
helm upgrade --install bitwarden --namespace bitwarden \
-f values.yaml \
--set bitwarden.smtp_password=$SMTP_PW \
--set bitwarden.smtp_username=$SMTP_USER \
--set bitwarden.smtp_host=$SMTP_ADDRESS \
--set bitwarden.server_admin_email=$BW_ADMIN_EMAIL \
--set bitwarden.duo_ikey=$BW_DUO_IKEY \
--set bitwarden.duo_skey=$BW_DUO_SKEY \
--set bitwarden.duo_host=$BW_DUO_API \
chartmuseum/bitwarden