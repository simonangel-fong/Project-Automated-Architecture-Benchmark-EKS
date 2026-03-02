# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

# add kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo
echo "# #################################"
echo "# Setup external lbc"
echo "# #################################"
echo

helm repo add eks --force-update https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME     \
    --set vpcId=$VPC_ID                 \
    --set serviceAccount.create=true    \
    --set serviceAccount.name=aws-load-balancer-controller      \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$IAM_LBC_ROLE_ARN   \
    --wait --timeout 10m

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
echo "# Setup external dns"
echo "# #################################"
echo

kubectl create ns external-dns --dry-run=client -o yaml | kubectl apply -f -

# create secret for cf
kubectl -n external-dns create secret generic cloudflare-api-key \
--from-literal=apiKey="$CF_TOKEN" \
--dry-run=client -o yaml | kubectl apply -f -

helm repo add external-dns --force-update https://kubernetes-sigs.github.io/external-dns/
helm repo update
helm upgrade --install external-dns external-dns/external-dns   \
    -n external-dns     \
    --create-namespace  \
    --set provider.name=cloudflare  \
    --set sources[0]=ingress        \
    --set policy=sync   \
    --set registry=txt  \
    --set domainFilters[0]=arguswatcher.net     \
    --set env[0].name=CF_API_TOKEN  \
    --set env[0].valueFrom.secretKeyRef.name=cloudflare-api-key     \
    --set env[0].valueFrom.secretKeyRef.key=apiKey

sleep 15

echo
echo "# #################################"
echo "# Setup external eso"
echo "# #################################"
echo

helm repo add --force-update external-secrets https://charts.external-secrets.io
helm repo update external-secrets
helm upgrade --install external-secrets external-secrets/external-secrets \
    -n external-secrets         \
    --create-namespace          \
    --version 2.0.1             \
    --set installCRDs=true      \
    --set serviceAccount.create=true    \
    --set serviceAccount.name=external-secrets      \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$IAM_ESO_ROLE_ARN

sleep 10

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