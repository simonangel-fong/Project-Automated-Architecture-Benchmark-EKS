#!/bin/bash

set -ef

REGION="__REGION__"
CLUSTER_NAME="__CLUSTER_NAME__"
VPC_ID="__VPC_ID__"

IAM_ESO_ROLE_ARN="__IAM_ESO_ROLE_ARN__"
IAM_LBC_ROLE_ARN="__IAM_LBC_ROLE_ARN__"

CF_TOKEN="__CF_TOKEN__"

# add kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo
echo "# #################################"
echo "# Setup external eso"
echo "# #################################"
echo

helm repo add external-secrets https://charts.external-secrets.io
helm repo update external-secrets
helm upgrade --install external-secrets external-secrets/external-secrets \
    -n external-secrets \
    --version 2.0.1 \
    --create-namespace \
    --set installCRDs=true

# Annotate sa
kubectl -n external-secrets annotate sa external-secrets eks.amazonaws.com/role-arn="$IAM_ESO_ROLE_ARN" --overwrite

kubectl apply -f manifest/baseline

echo
echo "# #################################"
echo "# Setup external lbc"
echo "# #################################"
echo

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system      \
    --version "3.1.0"   \
    --set clusterName=$CLUSTER_NAME \
    --set vpcId=$VPC_ID             \
    --set region=$REGION

kubectl annotate -n kube-system sa aws-load-balancer-controller eks.amazonaws.com/role-arn="IAM_LBC_ROLE_ARN" --overwrite

echo
echo "# #################################"
echo "# Setup external dns"
echo "# #################################"
echo

kubectl -n external-dns create secret generic cloudflare-api-key --from-literal=apiKey=$CF_TOKEN

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update
helm upgrade --install external-dns external-dns/external-dns \
    -n external-dns \
    --create-namespace \
    --set provider.name=cloudflare \
    --set sources[0]=ingress \
    --set policy=sync \
    --set registry=txt \
    --set domainFilters[0]=arguswatcher.net \
    --set env[0].name=CF_API_TOKEN \
    --set env[0].valueFrom.secretKeyRef.name=cloudflare-api-key \
    --set env[0].valueFrom.secretKeyRef.key=apiKey

echo
echo "# #################################"
echo "#  Apply Application"
echo "# #################################"
echo

kubectl apply -f manifest/baseline/ns.yaml
kubectl apply -f manifest/baseline/