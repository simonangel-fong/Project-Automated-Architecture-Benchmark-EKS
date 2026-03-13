## External Secret Operator

[Back](../README.md)

---

## ESO

- ref:
  - https://external-secrets.io/latest/
  - https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline

# #################################
# Setup external eso
# #################################
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true --version 2.0.1

# annotate sa
kubectl -n external-secrets annotate sa external-secrets eks.amazonaws.com/role-arn='IAM_ESO_ROLE_ARN'

kubectl apply -f k8s/baseline/eso/external-secret.yaml
# clustersecretstore.external-secrets.io/aws-secrets-global created
# externalsecret.external-secrets.io/app-cred created

```

---

- Debug

```sh
# #################################
# debug secret creation
# #################################
kubectl -n backend get clustersecretstore aws-secrets-global
# NAME                 AGE     STATUS   CAPABILITIES   READY
# aws-secrets-global   3m25s   Valid    ReadWrite      True

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
```
