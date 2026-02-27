## ESO

```sh
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true --version 2.0.1 --set serviceAccount.create=false --set serviceAccount.name=external-secrets



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

---
