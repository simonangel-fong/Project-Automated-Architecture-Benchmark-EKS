# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "#  Apply Application"
echo "# #################################"
echo

kubectl apply -f manifest/$ARCH/01_ns.yaml
kubectl apply -f manifest/$ARCH/02_cluste_secret_store.yaml
kubectl apply -f manifest/$ARCH/03_external_secrets.yaml
kubectl apply -f manifest/$ARCH/04_app_fastapi.yaml
kubectl apply -f manifest/$ARCH/05_ingress.yaml
kubectl apply -f manifest/$ARCH/06_hpa.yaml