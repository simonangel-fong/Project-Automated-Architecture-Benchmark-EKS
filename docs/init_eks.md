# EKS

[Back](../README.md)

- [EKS](#eks)
  - [AWS Init](#aws-init)


---

## AWS Init

```sh
cd infra/baseline

terraform init --backend-config=backend.config
terraform fmt && terraform validate
terraform apply -auto-approve
```
