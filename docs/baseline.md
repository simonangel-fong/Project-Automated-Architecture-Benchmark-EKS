# Architecture - Baseline

[Back](../README.md)

- [Architecture - Baseline](#architecture---baseline)
  - [AWS Init](#aws-init)
  - [Local Test](#local-test)
  - [Grafana k6 Testing](#grafana-k6-testing)

---

## AWS Init

```sh
# #################################
# init infra
# #################################
terraform -chdir=infra/baseline init --backend-config=backend.config
terraform -chdir=infra/baseline fmt && terraform -chdir=infra/baseline validate
terraform -chdir=infra/baseline apply -auto-approve

terraform -chdir=infra/baseline refresh
terraform -chdir=infra/baseline apply -destroy -auto-approve

# #################################
# add kubeconfig
# #################################
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline
```

---

## Local Test

```sh
# smoke
docker run --rm --name baseline_aws_smoke -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_smoke.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_smoke.js

# # read heavy
# docker run --rm --name baseline_aws_read -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_read.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_read.js

# # write heavy
# docker run --rm --name baseline_aws_write -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_write.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_write.js

# mixed
docker run --rm --name baseline_aws_mixed -p 5665:5665 -e SOLUTION_ID="baseline" -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/baseline_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```

---

## Grafana k6 Testing

```sh
# smoke
docker run --rm --name k6_baseline_aws_smoke --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e SOLUTION_ID=eks-baseline -e MAX_VU=100 -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_smoke.js

# # read
# docker run --rm --name k6_baseline_aws_smoke --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e SOLUTION_ID=eks-baseline -e MAX_VU=100 -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_hp_read.js

# # write
# docker run --rm --name k6_baseline_aws_write --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e SOLUTION_ID=eks-baseline -e MAX_VU=100 -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_hp_write.js

# mixed
docker run --rm --name k6_baseline_aws_mixed --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-baseline.arguswatcher.net" -e SOLUTION_ID=eks-baseline -e W_MAX_VU=50 -e R_MAX_VU=50 -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_hp_mixed.js
```
