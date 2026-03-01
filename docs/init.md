# Initialization

[Back](../README.md)

---

## AWS Init

```sh
# #################################
# init infra
# #################################
terraform -chdir=infra/baseline init --backend-config=backend.config
terraform -chdir=infra/baseline fmt && terraform -chdir=infra/baseline validate
terraform -chdir=infra/baseline apply -auto-approve

```

---

## EKS Cluster Init

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline
# Updated context ...cluster/eks-benchmark-baseline-cluster in .kube\config

# #################################
# Setup external eso
# #################################
helm repo add --force-update external-secrets https://charts.external-secrets.io
helm repo update external-secrets
helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets --version 2.0.1 --create-namespace --set installCRDs=true
# Release "external-secrets" does not exist. Installing it now.
# NAME: external-secrets
# LAST DEPLOYED: Sat Feb 28 13:42:10 2026
# NAMESPACE: external-secrets
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
# NOTES:
# external-secrets has been deployed successfully in namespace external-secrets!

# annotate sa
kubectl -n external-secrets annotate sa external-secrets eks.amazonaws.com/role-arn="IAM_ESO_ROLE_ARN" --overwrite
# serviceaccount/external-secrets annotated

kubectl apply -f manifest/baseline/external-secret.yaml
# clustersecretstore.external-secrets.io/aws-secrets-global created
# externalsecret.external-secrets.io/app-cred created

# #################################
# Setup external lbc
# #################################
helm repo add eks --force-update https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME     \
    --set vpcId=$VPC_ID                 \
    --set serviceAccount.create=true    \
    --set serviceAccount.name=aws-load-balancer-controller      \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$IAM_LBC_ROLE_ARN

# Release "aws-load-balancer-controller" does not exist. Installing it now.
# NAME: aws-load-balancer-controller
# LAST DEPLOYED: Sat Feb 28 13:53:00 2026
# NAMESPACE: kube-system
# STATUS: deployed
# REVISION: 1
# DESCRIPTION: Install complete
# TEST SUITE: None
# NOTES:
# AWS Load Balancer controller installed!

# #################################
# Setup external dns
# #################################
kubectl -n external-dns create secret generic cloudflare-api-key --from-literal=apiKey="cloud_token"

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
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
```

- Shell script

```sh
bash infra/script/init.sh
```

---

## Deploy Application

```sh
# #################################
# Apply Application
# #################################
kubectl apply -f manifest/init.yaml
kubectl apply -f manifest/baseline/

# confirm
kubectl -n backend get po
```

---

## Init DB Job

```sh
kubectl apply -f manifest/job/flyway.yaml
# job.batch/init-db-flyway created

kubectl -n backend logs -l job-name=init-db-flyway -f
# Migrating schema "public" to version "010 - create tb device registry"
# DB: trigger "trg_device_registry_set_updated_at" for relation "app.device_registry" does not exist, skipping
# Migrating schema "public" to version "011 - create tb telemetry event"
# Migrating schema "public" to version "012 - create tb telemetry latest"
# DB: trigger "trg_telemetry_event_upsert_latest" for relation "app.telemetry_event" does not exist, skipping
# Migrating schema "public" to version "013 - create tb telemetry latest outbox"
# DB: trigger "trg_telemetry_latest_outbox" for relation "app.telemetry_event" does not exist, skipping
# Migrating schema "public" to version "020 - seed tb device registry"
# Migrating schema "public" to version "021 - seed tb telemetry event"
# Successfully applied 11 migrations to schema "public", now at version v021 (execution time 00:01.522s)

kubectl -n backend get jobs
# NAME             STATUS     COMPLETIONS   DURATION   AGE
# init-db-flyway   Complete   1/1           27s        115s
```

---

## Debug

- remove ns

```sh
kubectl get ns backend -o json > ns.json

vi ns.json
# "spec": {
#   "finalizers": []
# }

kubectl replace --raw "/api/v1/namespaces/backend/finalize" -f ns.json
kubectl patch ingress nginx-alb -n backend -p '{"metadata":{"finalizers":null}}'
```

---

## Remove

```sh
kubectl delete -R -f manifest/baseline/
terraform -chdir=infra/baseline apply -destroy -auto-approve
```
