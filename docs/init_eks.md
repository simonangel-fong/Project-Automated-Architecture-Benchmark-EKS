# EKS

[Back](../README.md)

- [EKS](#eks)
  - [AWS Init](#aws-init)
  - [K8s Cluster](#k8s-cluster)


---

## AWS Init

```sh
cd infra/baseline

terraform init --backend-config=backend.config
terraform fmt && terraform validate
terraform apply -auto-approve
```

---

## K8s Cluster

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline-cluster
# Updated context ...cluster/eks-benchmark-baseline-cluster in .kube\config

kubectl config get-contexts
# CURRENT   NAME                                                                           CLUSTER                                                                        AUTHINFO                                                                       NAMESPACE
# *         arn:aws:eks:ca-central-1:099139718958:cluster/eks-benchmark-baseline-cluster   arn:aws:eks:ca-central-1:099139718958:cluster/eks-benchmark-baseline-cluster   arn:aws:eks:ca-central-1:099139718958:cluster/eks-benchmark-baseline-cluster
#           docker-desktop                                                                 docker-desktop                                                                 docker-desktop  

kubectl get po
```