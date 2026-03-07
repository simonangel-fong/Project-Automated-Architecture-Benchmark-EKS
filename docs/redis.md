# Architecture - Redis

[Back](../README.md)

- [Architecture - Redis](#architecture---redis)
  - [AWS Init](#aws-init)
  - [Test](#test)

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

# # read heavy
# docker run --rm --name redis_aws_read -p 5665:5665 -e SOLUTION_ID="redis" -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/redis_aws_read.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_read.js

# # write heavy
# docker run --rm --name redis_aws_write -p 5665:5665 -e SOLUTION_ID="redis" -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/redis_aws_write.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_write.js

# mixed
docker run --rm --name redis_aws_mixed -p 5665:5665 -e SOLUTION_ID="redis" -e BASE_URL="https://eks-benchmark-redis.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/redis_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```

---
