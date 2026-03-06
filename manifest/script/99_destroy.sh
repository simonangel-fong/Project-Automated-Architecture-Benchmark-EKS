#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "# Delete K8s Resource"
echo "# #################################"
echo

kubectl delete -f manifest/backend/$ARCH/05_ingress.yaml --ignore-not-found
