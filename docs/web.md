

## Upload Video file to s3

```sh
# Create a bucket
aws s3 mb s3://eks-benchmark.arguswatcher.net
# make_bucket: eks-benchmark.arguswatcher.net

# confirm
aws s3 ls
# 2026-03-13 11:10:03 eks-benchmark.arguswatcher.net

# create folder
aws s3 cp app/html/video s3://eks-benchmark.arguswatcher.net/video --recursive --exclude * --include *.mp4
# upload: app\html\video\github_action.mp4 to s3://eks-benchmark.arguswatcher.net/video/github_action.mp4
# upload: app\html\video\grafana_metrics.mp4 to s3://eks-benchmark.arguswatcher.net/video/grafana_metrics.mp4
# upload: app\html\video\project_video.mp4 to s3://eks-benchmark.arguswatcher.net/video/project_video.mp4

aws s3 ls s3://eks-benchmark.arguswatcher.net
# PRE video/
aws s3 ls s3://eks-benchmark.arguswatcher.net --recursive
# 2026-03-13 11:19:42    6632139 video/github_action.mp4
# 2026-03-13 11:19:42   10723716 video/grafana_metrics.mp4
# 2026-03-13 11:19:42   39168338 video/project_video.mp4

# delete object
aws s3 rm s3://eks-benchmark.arguswatcher.net/video/github_action.mp4
# delete: s3://eks-benchmark.arguswatcher.net/video/github_action.mp4

# delete an folder
aws s3 rm s3://eks-benchmark.arguswatcher.net/video/ --recursive
# delete: s3://eks-benchmark.arguswatcher.net/video/grafana_metrics.mp4
# delete: s3://eks-benchmark.arguswatcher.net/video/project_video.mp4

# delete a bucket
aws s3 rb s3://eks-benchmark.arguswatcher.net --force
# delete: s3://eks-benchmark.arguswatcher.net/video/grafana_metrics.mp4
# delete: s3://eks-benchmark.arguswatcher.net/video/project_video.mp4
# delete: s3://eks-benchmark.arguswatcher.net/video/github_action.mp4
# remove_bucket: eks-benchmark.arguswatcher.net

aws s3 ls s3://eks-benchmark.arguswatcher.net/
```

## Local TF

```sh
terraform -chdir=infra/web init --backend-config=backend.config
terraform -chdir=infra/web fmt && terraform -chdir=infra/web validate
terraform -chdir=infra/web apply -auto-approve
```