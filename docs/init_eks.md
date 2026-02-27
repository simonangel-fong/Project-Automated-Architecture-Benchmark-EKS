# Architecture - Baseline

[Back](../README.md)

- [Architecture - Baseline](#architecture---baseline)
  - [AWS Init](#aws-init)
  - [K8s Cluster](#k8s-cluster)
  - [Remove](#remove)
  - [ESO](#eso)

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

# confirm
kubectl -n backend get po
```

---

## Remove

```sh
kubectl delete -f k8s/baseline/ && terraform -chdir=infra/baseline destroy -auto-approve

terraform -chdir=infra/baseline destroy -auto-approve -target=helm_release.external_secrets
```

---

## ESO

```sh
kubectl apply -f k8s/baseline/secret_store.yaml
# clustersecretstore.external-secrets.io/aws-secrets-global created

kubectl -n backend get clustersecretstore aws-secrets-global
# NAME                 AGE     STATUS   CAPABILITIES   READY
# aws-secrets-global   3m25s   Valid    ReadWrite      True

kubectl apply -f k8s/baseline/external-secret.yaml
# externalsecret.external-secrets.io/app-cred created

kubectl -n backend get externalsecret app-cred
# NAME       STORETYPE            STORE                REFRESH INTERVAL   STATUS         READY
# app-cred   ClusterSecretStore   aws-secrets-global   1h0m0s             SecretSynced   True

kubectl -n backend describe externalsecret app-cred
# Events:
#   Type     Reason        Age                    From              Message
#   ----     ------        ----                   ----              -------
#   Normal   Created       72s                    external-secrets  secret created

kubectl -n backend get secret app-cred
# NAME       TYPE     DATA   AGE
# app-cred   Opaque   5      101s

kubectl -n backend get po
```
