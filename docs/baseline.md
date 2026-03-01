# Architecture - Baseline

[Back](../README.md)

- [Architecture - Baseline](#architecture---baseline)
  - [AWS Init](#aws-init)
  - [EKS Init](#eks-init)
  - [Remove](#remove)
  - [Test](#test)

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

## EKS Init

```sh
# #################################
# init k8s
# #################################
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline

# deploy app
kubectl apply -f manifest/baseline/backend/

# #################################
# init db
# #################################
kubectl replace --force -f manifest/job/flyway.yaml
# job.batch/init-db-flyway replaced

kubectl get -n backend job.batch/init-db-flyway 
```

---

## Remove

```sh
kubectl delete -R -f manifest/baseline/ && terraform -chdir=infra/baseline apply -destroy -auto-approve
```

---

## Test

```sh
# smoke
docker run --rm --name baseline_aws_smoke -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_smoke.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_smoke.js

# read heavy
docker run --rm --name baseline_aws_read -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_read.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_read.js

# write heavy
docker run --rm --name baseline_aws_write -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_write.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_write.js

# mixed
docker run --rm --name baseline_aws_mixed -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```

---
