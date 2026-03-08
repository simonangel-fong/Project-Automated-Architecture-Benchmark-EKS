#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "# Delete K8s Resource"
echo "# #################################"
echo

# remove 
kubectl delete -f manifest/backend/$ARCH/06_ingress.yaml --ignore-not-found
kubectl delete -f manifest/backend/$ARCH/02_karpenter.yaml --ignore-not-found
