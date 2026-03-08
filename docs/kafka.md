# Architecture - Kafka

[Back](../README.md)

- [Architecture - Kafka](#architecture---kafka)
  - [App](#app)
  - [AWS Init](#aws-init)
  - [Test](#test)

---

## App 

- Init

```sh
# build
docker build -t msk-topic-admin app/kafka/init
# tag
docker tag msk-topic-admin 099139718958.dkr.ecr.ca-central-1.amazonaws.com/auto-benchmark:msk-topic-admin
# push to docker
docker push 099139718958.dkr.ecr.ca-central-1.amazonaws.com/auto-benchmark:msk-topic-admin
```


---

## AWS Init

```sh
# #################################
# init infra
# #################################
terraform -chdir=infra/kafka init --backend-config=backend.config
terraform -chdir=infra/kafka fmt && terraform -chdir=infra/kafka validate
terraform -chdir=infra/kafka plan
terraform -chdir=infra/kafka apply -auto-approve

terraform -chdir=infra/kafka refresh
terraform -chdir=infra/kafka output
terraform -chdir=infra/kafka apply -destroy -auto-approve

# #################################
# add kubeconfig
# #################################
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-kafka

# #################################
# Init kafka
# #################################
kubectl apply -f manifest/job/kafka.yaml
```

---

## Test

```sh
# smoke
docker run --rm --name kafka_aws_smoke -p 5665:5665 -e SOLUTION_ID="kafka" -e BASE_URL="https://eks-benchmark-kafka.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/kafka_aws_smoke.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_smoke.js

# # read heavy
# docker run --rm --name kafka_aws_read -p 5665:5665 -e SOLUTION_ID="kafka" -e BASE_URL="https://eks-benchmark-kafka.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/kafka_aws_read.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_read.js

# # write heavy
# docker run --rm --name kafka_aws_write -p 5665:5665 -e SOLUTION_ID="kafka" -e BASE_URL="https://eks-benchmark-kafka.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/kafka_aws_write.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_write.js

# mixed
docker run --rm --name kafka_aws_mixed -p 5665:5665 -e SOLUTION_ID="kafka" -e BASE_URL="https://eks-benchmark-kafka.arguswatcher.net" -e K6_WEB_DASHBOARD=true -e K6_WEB_DASHBOARD_EXPORT=/report/kafka_aws_mixed.html -e K6_WEB_DASHBOARD_PERIOD=3s -v ./test/k6/script:/script -v ./test/k6/report:/report/ grafana/k6 run /script/test_hp_mixed.js
```

---
