# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

# add kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo
echo "# #################################"
echo "# Delete K8s Resource"
echo "# #################################"
echo

kubectl delete -f ./$ARCH/05_ingress.yaml
kubectl delete -f ./$ARCH/04_app_fastapi.yaml
kubectl delete -f ./$ARCH/03_external_secrets.yaml
kubectl delete -f ./$ARCH/02_cluste_secret_store.yaml
kubectl delete -f ./$ARCH/01_ns.yaml

echo
echo "# #################################"
echo "# Uninstall Helm packages"
echo "# #################################"
echo

helm uninstall -n external-dns external-dns 
helm uninstall -n kube-system aws-load-balancer-controller
helm uninstall -n external-secrets external-secrets 
