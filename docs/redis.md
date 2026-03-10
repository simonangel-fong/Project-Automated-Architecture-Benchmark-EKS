# Architecture - Redis

[Back](../README.md)

- [Architecture - Redis](#architecture---redis)
  - [AWS Init](#aws-init)
  - [Test](#test)
  - [Grafana k6 Testing](#grafana-k6-testing)

---

## AWS Init

```sh
# #################################
# init infra
# #################################
terraform -chdir=infra/redis init --backend-config=backend.config
terraform -chdir=infra/redis fmt && terraform -chdir=infra/redis validate
terraform -chdir=infra/redis apply -auto-approve

terraform -chdir=infra/redis refresh
terraform -chdir=infra/redis apply -destroy -auto-approve

# #################################
# add kubeconfig
# #################################
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-redis
```

---

## Test

```sh
# smoke
docker run --rm --name redis_aws_smoke -p 5665:5665 -e SOLUTION_ID="redis" -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/redis_aws_smoke.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_smoke.js

# mixed
docker run --rm --name redis_aws_mixed -p 5665:5665 -e SOLUTION_ID="redis" -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/redis_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```

---

## Grafana k6 Testing

```sh
# smoke
docker run --rm --name k6_redis_aws_smoke --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e SOLUTION_ID=eks-redis -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_smoke.js

# mixed
docker run --rm --name k6_redis_aws_mixed --env-file ./test/k6/.env -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e SOLUTION_ID=eks-redis -e W_MAX_VU=50 -e R_MAX_VU=50 -v ./test/k6/script:/script grafana/k6 cloud run --include-system-env-vars=true /script/test_hp_mixed.js
```
