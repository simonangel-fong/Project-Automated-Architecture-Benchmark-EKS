# Architecture - Baseline

[Back](../README.md)

- [Architecture - Baseline](#architecture---baseline)
  - [AWS Init](#aws-init)
  - [K8s Cluster](#k8s-cluster)
  - [Remove](#remove)
  - [Init DB Job](#init-db-job)
  - [Update DNS](#update-dns)
  - [Test](#test)

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
terraform -chdir=infra/baseline destroy -auto-approve -target=cloudflare_record.dns_record

kubectl delete -f k8s/baseline/ && terraform -chdir=infra/baseline destroy -auto-approve
```

---

## Init DB Job

```sh
kubectl apply -f k8s/baseline/flyway.yaml
kubectl -n backend logs -l job-name=init-db-flyway -f
kubectl -n backend get jobs
```

---

## Update DNS

```sh
# update dns when ingress integrated with alb gets updated
terraform -chdir=infra/baseline apply -target=cloudflare_record.dns_record -auto-approve
```

---

## Test

```sh
# smoke
docker run --rm --name baseline_aws_smoke -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://benchmark-eks-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_smoke.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_smoke.js

# read heavy
docker run --rm --name baseline_aws_read -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://benchmark-eks-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_read.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_read.js

# write heavy
docker run --rm --name baseline_aws_write -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://benchmark-eks-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_write.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_write.js

# mixed
docker run --rm --name baseline_aws_mixed -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://benchmark-eks-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```