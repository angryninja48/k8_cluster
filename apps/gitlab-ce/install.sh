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
helm install --name gitlab --namespace gitlab -f ./values.yaml \
--set postgres.password=$GITLAB_POSTGRES_PW \
--set redis.password=$GITLAB_REDIS_PW \
--set gitlab.smtp.password=$SMTP_PW \
--set gitlab.smtp.user=$SMTP_USER \
--set gitlab.smtp.address=$SMTP_ADDRESS \
chartmuseum/gitlab-ce
