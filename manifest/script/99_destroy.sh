#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "# Delete K8s Resource"
echo "# #################################"
echo

kubectl delete -f manifest/$ARCH/06_ingress.yaml --ignore-not-found
