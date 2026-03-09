# 02_init_deploy_backend
#!/bin/bash

set -Eeuo pipefail

kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=10m

echo
echo "# #################################"
echo "#  Deploy Application"
echo "# #################################"
echo

kubectl create -f manifest/backend/$ARCH/01_karpenter.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/01_karpenter.yaml
kubectl create -f manifest/backend/$ARCH/02_cluster_secret_store.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/02_cluster_secret_store.yaml
kubectl create -f manifest/backend/$ARCH/03_app_fastapi.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/03_app_fastapi.yaml

if [[ "$ARCH" == "kafka" ]]; then
  kubectl create -f manifest/backend/$ARCH/04_app_kafka_comsumer.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/04_app_kafka_comsumer.yaml
  kubectl create -f manifest/backend/$ARCH/05_app_outbox.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/05_app_outbox.yaml
fi

# ingress
kubectl create -f manifest/backend/$ARCH/99_ingress.yaml 2>/dev/null || kubectl replace -f manifest/backend/$ARCH/99_ingress.yaml

########################################
echo
echo "# #################################"
echo "#  Init PGDB"
echo "# #################################"
echo

kubectl create -f manifest/job/flyway.yaml 2>/dev/null || kubectl replace -f manifest/job/flyway.yaml

########################################

if [[ "$ARCH" == "kafka" ]]; then
  echo
  echo "# #################################"
  echo "#  Init Kafka"
  echo "# #################################"
  echo

  kubectl create -f manifest/job/kafka.yaml 2>/dev/null || kubectl replace -f manifest/job/kafka.yaml
fi