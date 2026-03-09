#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "# Delete K8s Resource"
echo "# #################################"
echo

# remove 
kubectl delete -f manifest/backend/$ARCH/99_ingress.yaml --ignore-not-found
kubectl delete -f manifest/backend/$ARCH/01_karpenter.yaml --ignore-not-found
