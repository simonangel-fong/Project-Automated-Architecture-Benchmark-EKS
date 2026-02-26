# Architecture - Baseline

[Back](../README.md)

- [Architecture - Baseline](#architecture---baseline)
  - [AWS Init](#aws-init)
  - [K8s Cluster](#k8s-cluster)
  - [Remove](#remove)

---

## AWS Init

```sh
terraform -chdir=infra/baseline init --backend-config=backend.config
terraform -chdir=infra/baseline fmt && terraform -chdir=infra/baseline validate
terraform -chdir=infra/baseline apply -auto-approve

```

---

## K8s Cluster

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline
# Updated context ...cluster/eks-benchmark-baseline-cluster in .kube\config

# kubectl config get-contexts
# kubectl config delete-context

kubectl apply -f k8s/baseline/
kubectl apply -f k8s/baseline/secret_store.yaml
kubectl apply -f k8s/baseline/external-secret.yaml
```

---

## Remove

```sh
kubectl delete -f k8s/baseline/ && terraform -chdir=infra/baseline destroy -auto-approve

terraform -chdir=infra/baseline destroy -auto-approve -target=helm_release.external_secrets
```
