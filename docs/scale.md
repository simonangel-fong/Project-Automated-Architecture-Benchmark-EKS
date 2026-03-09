# Architecture - Scale

[Back](../README.md)

- [Architecture - Scale](#architecture---scale)
  - [AWS Init](#aws-init)
  - [Test](#test)
  - [Grafana k6 Testing](#grafana-k6-testing)

---

## AWS Init

```sh
# #################################
# init infra
# #################################
terraform -chdir=infra/scale init --backend-config=backend.config
terraform -chdir=infra/scale fmt && terraform -chdir=infra/scale validate
terraform -chdir=infra/scale apply -auto-approve

terraform -chdir=infra/scale refresh && terraform -chdir=infra/scale output
terraform -chdir=infra/scale apply -destroy -auto-approve

# #################################
# add kubeconfig
# #################################
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-scale
# Added new context arn:aws:eks:ca-central-1:099139718958:cluster/eks-benchmark-scale to .kube\config
```

---

## Test

```sh
# smoke
docker run --rm --name scale_aws_smoke -p 5665:5665 -e SOLUTION_ID="scale" -e BASE_URL="https://eks-benchmark-scale.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/scale_aws_smoke.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_smoke.js

# # read heavy
# docker run --rm --name scale_aws_read -p 5665:5665 -e SOLUTION_ID="scale" -e BASE_URL="https://eks-benchmark-scale.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/scale_aws_read.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_read.js

# # write heavy
# docker run --rm --name scale_aws_write -p 5665:5665 -e SOLUTION_ID="scale" -e BASE_URL="https://eks-benchmark-scale.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/scale_aws_write.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_write.js

# mixed
docker run --rm --name scale_aws_mixed -p 5666:5665 -e SOLUTION_ID="scale" -e BASE_URL="https://eks-benchmark-scale.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/scale_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```

---

## Grafana k6 Testing

```sh
# smoke
docker run --rm --name k6_scale_aws_smoke --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-scale.arguswatcher.net" -e SOLUTION_ID=eks-scale -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_smoke.js

# mixed
docker run --rm --name k6_scale_aws_mixed --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-scale.arguswatcher.net" -e SOLUTION_ID=eks-scale -e W_MAX_VU=50 -e R_MAX_VU=50 -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_hp_mixed.js
```
