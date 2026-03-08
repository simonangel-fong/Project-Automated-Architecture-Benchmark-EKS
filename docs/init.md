# Initialization

[Back](../README.md)

---

## EKS Cluster Init

### Add-on

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline
# Updated context ...cluster/eks-benchmark-baseline-cluster in .kube\config

# #################################
# Setup external eso
# #################################
helm upgrade --install  external-secrets external-secrets   \
    --repo https://charts.external-secrets.io   \
    -n external-secrets --create-namespace      \
    --version 2.0.1                             \
    --set installCRDs=true
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
kubectl -n external-secrets annotate sa external-secrets eks.amazonaws.com/role-arn="$IAM_ESO_ROLE_ARN" --overwrite
# serviceaccount/external-secrets annotated

kubectl apply -f manifest/addon/01_external_secrets.yaml


# #################################
# Setup external lbc
# #################################
helm upgrade --install  aws-load-balancer-controller aws-load-balancer-controller   \
    --repo https://aws.github.io/eks-charts     \
    -n kube-system                      \
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

# #################################
# Setup Kerpenter
# #################################

helm registry logout public.ecr.aws

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --namespace kube-system \
  --set settings.clusterName="${CLUSTER_NAME}" \
  --set settings.interruptionQueue="${QUEUE_NAME}" \
  --set webhook.enabled=true \
  --wait


helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --namespace kube-system --set settings.clusterName="eks-benchmark-baseline" --set settings.interruptionQueue="Karpenter-eks-benchmark-baseline" --set webhook.enabled=true --wait

```

### Deploy Backend

```sh
# #################################
# Init backend
# #################################
kubectl apply -f manifest/backend_scale/01_ns.yaml
kubectl apply -f manifest/backend_scale/02_karpenter.yaml
kubectl apply -f manifest/backend_scale/03_external_secrets.yaml
kubectl apply -f manifest/backend_scale/04_app_fastapi.yaml
kubectl apply -f manifest/backend_scale/05_ingress.yaml
kubectl apply -f manifest/backend_scale/06_hpa.yaml

# #################################
# Init rds
# #################################
kubectl apply -f manifest/job/flyway.yaml

# #################################
# Init kafka
# #################################
kubectl apply -f manifest/job/kafka.yaml
```

### Using Shell Script

```sh
bash manifest/script/01_init_add_on.sh
bash manifest/script/02_init_deploy_backend.sh
bash manifest/script/03_init_rds.sh
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


# secret managers
aws secretsmanager delete-secret --secret-id secret_id --region aws_region --force-delete-without-recovery
```

---

## Remove

```sh
kubectl delete -R -f manifest/baseline/
terraform -chdir=infra/baseline apply -destroy -auto-approve
```

---

## Access Control

| Identity               | Purpose                                   | EKS Access Policy             | K8s Permission Level                                                                  |
| ---------------------- | ----------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------- |
| Infra-Provisioner-Role | "Terraform: EKS, VPC, AWS Add-ons."       | `AmazonEKSClusterAdminPolicy` | Full Admin: Needs to manage cluster-wide system settings and AWS integrations.        |
| App-Deployer-Role      | Helm: App-specific add-ons and manifests. | `AmazonEKSAdminPolicy`        | "Resource Admin: High-level access to create Namespaces, CRDs, and deploy workloads." |

| Persona   | Purpose                            | EKS Access Policy             | Scope                                                  |
| --------- | ---------------------------------- | ----------------------------- | ------------------------------------------------------ |
| Admin     | Daily Ops / Emergency Break-Glass. | `AmazonEKSClusterAdminPolicy` | Cluster-wide: Full visibility and control.             |
| Developer | App debugging and log viewing.     | `AmazonEKSEditPolicy`         | Namespace-bound: Restricted to app-\* namespaces only. |
| Auditor   | Compliance & Reporting.            | `AmazonEKSViewPolicy`         | Cluster-wide: Read-only (GET/LIST). No write/delete.   |
