# 02_init_deploy_backend
#!/bin/bash

set -Eeuo pipefail

kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=10m

echo
echo "# #################################"
echo "#  Deploy Application"
echo "# #################################"
echo

kubectl delete -f manifest/backend/$ARCH/01_karpenter.yaml --ignore-not-found
kubectl apply -f manifest/backend/$ARCH/01_karpenter.yaml

kubectl delete -f manifest/backend/$ARCH/02_cluster_secret_store.yaml --ignore-not-found
kubectl apply -f manifest/backend/$ARCH/02_cluster_secret_store.yaml

kubectl delete -f manifest/backend/$ARCH/03_app_fastapi.yaml --ignore-not-found
kubectl apply -f manifest/backend/$ARCH/03_app_fastapi.yaml


if [[ "$ARCH" == "kafka" ]]; then
  kubectl delete -f manifest/backend/$ARCH/04_app_kafka_comsumer.yaml --ignore-not-found
  kubectl apply -f manifest/backend/$ARCH/04_app_kafka_comsumer.yaml

  kubectl delete -f manifest/backend/$ARCH/05_app_outbox.yaml --ignore-not-found
  kubectl apply -f manifest/backend/$ARCH/05_app_outbox.yaml
fi

# ingress
kubectl delete -f manifest/backend/$ARCH/99_ingress.yaml --ignore-not-found
kubectl apply -f manifest/backend/$ARCH/99_ingress.yaml

########################################
echo
echo "# #################################"
echo "#  Init PGDB"
echo "# #################################"
echo

kubectl delete -f manifest/job/flyway.yaml --ignore-not-found
kubectl apply -f manifest/job/flyway.yaml

########################################

if [[ "$ARCH" == "kafka" ]]; then
  echo
  echo "# #################################"
  echo "#  Init Kafka"
  echo "# #################################"
  echo

  kubectl delete -f manifest/job/kafka.yaml --ignore-not-found
  kubectl apply -f manifest/job/kafka.yaml
fi