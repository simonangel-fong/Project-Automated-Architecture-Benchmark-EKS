# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

# add kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo
echo "# #################################"
echo "# Setup external eso"
echo "# #################################"
echo
helm upgrade --install  external-secrets external-secrets   \
    --repo https://charts.external-secrets.io   \
    -n external-secrets --create-namespace      \
    --version 2.0.1                             \
    --set installCRDs=true

kubectl -n external-secrets annotate sa external-secrets eks.amazonaws.com/role-arn="$IAM_ESO_ROLE_ARN" --overwrite

echo
echo "# #################################"
echo "# Setup external albc"
echo "# #################################"
echo
helm upgrade --install  aws-load-balancer-controller aws-load-balancer-controller   \
    --repo https://aws.github.io/eks-charts     \
    -n kube-system                      \
    --set clusterName=$CLUSTER_NAME     \
    --set vpcId=$VPC_ID                 \
    --set serviceAccount.create=true    \
    --set serviceAccount.name=aws-load-balancer-controller      \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$IAM_LBC_ROLE_ARN

sleep 10

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

helm upgrade --install  external-dns external-dns           \
    --repo https://kubernetes-sigs.github.io/external-dns   \
    -n external-dns --create-namespace      \
    --set provider.name=cloudflare          \
    --set sources[0]=ingress                \
    --set policy=sync                       \
    --set registry=txt                      \
    --set txtOwnerId="${CLUSTER_NAME}"      \
    --set domainFilters[0]=arguswatcher.net \
    --set env[0].name=CF_API_TOKEN          \
    --set env[0].valueFrom.secretKeyRef.name=cloudflare-api-key     \
    --set env[0].valueFrom.secretKeyRef.key=apiKey  

sleep 10

echo
echo "# #################################"
echo "# Setup Karpenter"
echo "# #################################"
echo
helm registry logout public.ecr.aws
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --namespace kube-system \
  --version "1.9.0" 
  --set settings.clusterName="${CLUSTER_NAME}" \
  --set settings.interruptionQueue="${QUEUE_NAME}" \
  --set webhook.enabled=true \
  --wait \
  --timeout 10m \
  --debug

sleep 10

echo
echo "# #################################"
echo "# Add-on installed Completed."
echo "# #################################"
echo