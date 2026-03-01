## External DNS

[Back](../README.md)

---

## Setup External DNS

- ref:
  - https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/cloudflare/#using-helm

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline

# #################################
# Setup external dns
# #################################
# create secret: cf token
kubectl create secret generic cloudflare-api-key --from-literal=apiKey="cloud_token"

# install eDNS
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update
helm upgrade --install external-dns external-dns/external-dns -n external-dns --create-namespace --values values.yaml

# apply app with ingress
kubectl apply -f manifest/baseline
```

- Test

```sh
# test
curl https://eks-benchmark-baseline.arguswatcher.net/

curl -v "http://eks-benchmark-baseline-570625218.ca-central-1.elb.amazonaws.com/api/health" -H "Host: eks-benchmark-baseline.arguswatcher.net"
# * Host eks-benchmark-baseline-570625218.ca-central-1.elb.amazonaws.com:80 was resolved.
# * IPv6: (none)
# * IPv4: 52.60.112.91, 16.52.14.127, 15.222.66.53
# *   Trying 52.60.112.91:80...
# * Connected to eks-benchmark-baseline-570625218.ca-central-1.elb.amazonaws.com (52.60.112.91) port 80
# > GET /api/health HTTP/1.1
# > Host: eks-benchmark-baseline.arguswatcher.net
# > User-Agent: curl/8.5.0
# > Accept: */*
# >
# < HTTP/1.1 301 Moved Permanently
# < Server: awselb/2.0
# < Date: Sat, 28 Feb 2026 23:39:58 GMT
# < Content-Type: text/html
# < Content-Length: 134
# < Connection: keep-alive
# < Location: https://eks-benchmark-baseline.arguswatcher.net:443/api/health

curl http://eks-benchmark-baseline.arguswatcher.net/api/
```

- Debug

```sh
# #################################
# Debug: cloudflare token
# #################################
kubectl get po -l app.kubernetes.io/name=external-dns
# NAME                            READY   STATUS    RESTARTS   AGE
# external-dns-5d8cb4477d-x2xrb   1/1     Running   0          5m8s

kubectl logs external-dns-5d8cb4477d-
# ...
# time="2026-02-28T15:42:58Z" level=info msg="Instantiating new Kubernetes client"
# time="2026-02-28T15:42:58Z" level=info msg="Using inCluster-config based on serviceaccount-token"
# time="2026-02-28T15:42:58Z" level=info msg="Created Kubernetes client https://172.20.0.1:443"
# time="2026-02-28T15:43:02Z" level=info msg="All records are already up to date"
# time="2026-02-28T15:44:02Z" level=info msg="All records are already up to date"
```
