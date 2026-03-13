## AWS Load Balancer Controller

[Back](../README.md)

---

## Document method

- ref:
  - https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline

# IAM
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region ca-central-1 --cluster eks-benchmark-baseline --approve

eksctl create iamserviceaccount --cluster eks-benchmark-baseline --namespace kube-system --name aws-load-balancer-controller --attach-policy-arn arn:aws:iam::AWS_ID:policy/AWSLoadBalancerControllerIAMPolicy   --override-existing-serviceaccounts --approve
```

- helm

```sh
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eks-benchmark-baseline --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eks-benchmark-baseline --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=ca-central-1 --set vpcId=VPC_ID


# confirm
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system get pods -l app.kubernetes.io/name=aws-load-balancer-controller

```

---

## Method: IAM + helm

- ref:
  - https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/
  - https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller

```sh
# add kubeconfig
aws eks update-kubeconfig --region ca-central-1 --name eks-benchmark-baseline

# #################################
# Setup external lbc
# #################################
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --version "3.1.0" --values manifest/helm/values-lbc.yaml

# annotate sa
kubectl annotate -n kube-system sa aws-load-balancer-controller eks.amazonaws.com/role-arn="IAM_LBC_ROLE_ARN" --overwrite
# serviceaccount/aws-load-balancer-controller annotated

# confirm
kubectl describe -n kube-system sa aws-load-balancer-controller

# Testing
kubectl replace --force -f k8s/baseline/backend
```

---

- Debug

```sh
# confirm
kubectl -n kube-system get deployment aws-load-balancer-controller
# NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
# aws-load-balancer-controller   2/2     2            2           26m

kubectl -n kube-system get pods -l app.kubernetes.io/name=aws-load-balancer-controller
# NAME                                           READY   STATUS    RESTARTS   AGE
# aws-load-balancer-controller-bcdd55577-nhj99   1/1     Running   0          29s
# aws-load-balancer-controller-bcdd55577-nwm7d   1/1     Running   0          42s

kubectl -n kube-system logs aws-load-balancer-controller-bcdd55577-nhj99
```
