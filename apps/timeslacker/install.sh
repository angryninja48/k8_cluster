#!/usr/bin/env bash

set -e
set -o pipefail

if ! command -v kubectl > /dev/null; then
  echo "kubectl command not installed"
  exit 1
fi

echo -n "Installing deployment... "

kubectl apply -f namespace.yml

TS_USER_B64=`echo $TS_USER | base64`
TS_PASSWORD_B64=`echo $TS_PASSWORD | base64`
SLACK_TOKEN_B64=`echo $SLACK_TOKEN | base64`
TIME_SHEET_URL_B64=`echo $TIME_SHEET_URL | base64`
SLACK_SIGNING_SECRET_B64=`echo $SLACK_SIGNING_SECRET | base64`

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: timeslacker
  namespace: timeslacker
type: Opaque
data:
  TS_USER: $TS_USER_B64
  TS_PASSWORD: $TS_PASSWORD_B64
  SLACK_TOKEN: $SLACK_TOKEN_B64
  TIME_SHEET_URL: $TIME_SHEET_URL_B64
  SLACK_SIGNING_SECRET: $SLACK_SIGNING_SECRET_B64
EOF

kubectl apply -f deployment.yml
