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

echo -n "Installing helm chart... "
helm upgrade --install gitlab-runner --namespace gitlab -f ./values.yaml \
--set runnerRegistrationToken=$GITLAB_RUNNER_REGISTRATION \
gitlab/gitlab-runner
