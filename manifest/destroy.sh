# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

# # add kubeconfig
# aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo
echo "# #################################"
echo "# Delete K8s Resource"
echo "# #################################"
echo

kubectl delete -f manifest/$ARCH/05_ingress.yaml --ignore-not-found
# kubectl delete -f manifest/$ARCH/04_app_fastapi.yaml --ignore-not-found
# kubectl delete -f manifest/$ARCH/03_external_secrets.yaml --ignore-not-found
# kubectl delete -f manifest/$ARCH/02_cluste_secret_store.yaml --ignore-not-found
# kubectl delete -f manifest/$ARCH/01_ns.yaml --ignore-not-found

# echo
# echo "# #################################"
# echo "# Uninstall Helm packages"
# echo "# #################################"
# echo

# helm uninstall -n external-dns external-dns 
# helm uninstall -n kube-system aws-load-balancer-controller
# helm uninstall -n external-secrets external-secrets 
