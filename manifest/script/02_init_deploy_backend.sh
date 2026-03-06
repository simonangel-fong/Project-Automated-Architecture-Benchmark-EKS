# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

# rollout
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=10m

# Check if lbc ready
for i in {1..60}; do
  EP=$(kubectl get endpoints -n kube-system aws-load-balancer-webhook-service -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)
  if [ -n "$EP" ]; then
    echo "Webhook endpoints ready: $EP"
    break
  fi
  echo "Waiting for aws-load-balancer-webhook-service endpoints..."
  sleep 5
done

echo
echo "# #################################"
echo "#  Apply Application"
echo "# #################################"
echo

kubectl create -f manifest/backend/$ARCH/01_ns.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/01_ns.yaml
kubectl create -f manifest/backend/$ARCH/02_karpenter.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/02_karpenter.yaml
kubectl create -f manifest/backend/$ARCH/03_external_secrets.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/03_external_secrets.yaml
kubectl create -f manifest/backend/$ARCH/04_app_fastapi.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/04_app_fastapi.yaml
kubectl create -f manifest/backend/$ARCH/05_ingress.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/05_ingress.yaml
kubectl create -f manifest/backend/$ARCH/06_hpa.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/06_hpa.yaml

