## Enable ALB controller

```sh
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region ca-central-1 --cluster eks-benchmark-baseline --approve

eksctl create iamserviceaccount --cluster eks-benchmark-baseline --namespace kube-system --name aws-load-balancer-controller --attach-policy-arn arn:aws:iam::AWS_ID:policy/AWSLoadBalancerControllerIAMPolicy   --override-existing-serviceaccounts --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eks-benchmark-baseline --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eks-benchmark-baseline --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=ca-central-1 --set vpcId=VPC_ID


# confirm
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system get pods -l app.kubernetes.io/name=aws-load-balancer-controller

```
