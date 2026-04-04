# Automated Architecture Benchmark (EKS) - EKS Challenges

[Back](../../README.md)

- [Automated Architecture Benchmark (EKS) - EKS Challenges](#automated-architecture-benchmark-eks---eks-challenges)
  - [Terraform(IaC \& AWS)](#terraformiac--aws)
    - [Terraform Module](#terraform-module)
    - [Terraform vs Helm](#terraform-vs-helm)
    - [Secret \& Config Management](#secret--config-management)
    - [Secure Connection Between Cluster and RDS / ElastiCache / MSK](#secure-connection-between-cluster-and-rds--elasticache--msk)
    - [Multi-region / Multi-account Design](#multi-region--multi-account-design)
  - [EKS Cluster](#eks-cluster)
    - [EKS Auto-scaling](#eks-auto-scaling)
    - [Managed vs Self-hosted Services](#managed-vs-self-hosted-services)
    - [Cluster Access](#cluster-access)
    - [EKS Add-ons](#eks-add-ons)
    - [Additional Add-ons (Non-EKS Managed)](#additional-add-ons-non-eks-managed)
    - [External Secrets Operator](#external-secrets-operator)
    - [External DNS](#external-dns)
    - [AWS Load Balancer Controller](#aws-load-balancer-controller)

---

## Terraform(IaC & AWS)

### Terraform Module

- **What Terraform modules are**
  - Reusable components to define infrastructure
  - Common modules: VPC, subnets, IAM, EKS cluster

- **Module structure in my project**
  - Each architecture (Baseline, Scale, Redis, Kafka) has its **own module**
  - Reason: each design uses **different services and configurations**
  - Avoids complex conditional logic in a single module

- **EKS module**
  - Used **official AWS EKS Managed Node Group module**
  - to reduced complexity

---

### Terraform vs Helm

- **Terraform**
  - Manages AWS infrastructure
  - Example: EKS, RDS, ElastiCache, MSK, VPC

- **Helm**
  - Manages Kubernetes applications
  - Example: FastAPI app, HPA, Redis/Kafka deployment

- **Why both**
  - Clear separation:
    - Infra layer (Terraform)
    - App layer (Helm)

- **Pipeline flow**
  - Terraform → outputs cluster info
  - Helm → deploy app using those outputs

---

### Secret & Config Management

- **GitHub Actions**
  - Use **OIDC federation** to access AWS → no long-lived credentials
  - Store sensitive values in **GitHub encrypted secrets**
  - Secrets are injected at runtime, never hardcoded

- **Terraform**
  - Store sensitive data (e.g., RDS password) in `terraform.tfvars` locally and **`AWS Secrets Manager`** on cloud.
  - Pass variables using `TF_VAR_*` environment variables
  - Mark sensitive values in Terraform to avoid exposure in logs

- **Kubernetes (Cluster level)**
  - Use **External Secrets Operator** to sync secrets from `AWS Secrets Manager`
  - Inject secrets into pods via **environment variables**

- **Overall Design**
  - No sensitive data stored in plaintext
  - Centralized secret management (AWS Secrets Manager)
  - Short-lived credentials (OIDC)
  - Clear separation between:
    - CI/CD layer
    - Infrastructure layer
    - Application layer

---

### Secure Connection Between Cluster and RDS / ElastiCache / MSK

- **Network design**
  - All resources (EKS, RDS, ElastiCache, MSK) are deployed in the **same VPC**
  - Services are placed in **private subnets** (no public exposure)

- **Access control**
  - EKS worker nodes are associated with a **node Security Group**
  - RDS / ElastiCache / MSK Security Groups allow **inbound traffic only from the EKS node SG**
  - No open CIDR ranges (e.g., `0.0.0.0/0`)

- **Why**
  - Enforces **least privilege network access**
  - Ensures only workloads inside the cluster can reach backend services
  - Prevents external access to databases and cache

---

### Multi-region / Multi-account Design

- **Multi-account**
  - Separate accounts:
    - dev / staging / prod
  - Use IAM roles for cross-account access

- **Multi-region**
  - Separate Terraform state per region
  - Parameterized modules

- **Data layer**
  - RDS → Aurora Global / read replicas
  - Redis → Global Datastore
  - Kafka → MirrorMaker

- **Routing**
  - Route53 latency-based routing

- **Purpose**
  - Reduce latency
  - Improve resilience

---

## EKS Cluster

### EKS Auto-scaling

- **Cluster Layer (Pod scaling)**
  - Use **Horizontal Pod Autoscaler (HPA)**
  - Scale pods based on CPU utilization
    - `targetCPUUtilizationPercentage: 40%`
    - Min: 1, Max: 20

- **Node Layer (Infrastructure scaling)**
  - Use **Karpenter** for node provisioning
  - Automatically launches nodes when pods are **unschedulable**
  - Installed via Terraform module
  - Configured using:
    - `NodeClass` (infrastructure config)
    - `NodePool` (scaling behavior)

- **Behavior**
  - HPA scales pods first based on load
  - If pods cannot be scheduled → **Karpenter provisions new nodes**
  - Ensures fast and efficient scaling without pre-provisioned capacity

- **Why Karpenter**
  - Faster scaling compared to Cluster Autoscaler
  - Better bin-packing and cost efficiency
  - No need to manage node groups manually

---

### Managed vs Self-hosted Services

- **Managed (ElastiCache, MSK)**
  - Pros:
    - HA, failover, monitoring
    - No operational overhead
  - Cons:
    - Higher cost
    - Less control

- **Self-hosted (EKS)**
  - Pros:
    - Lower cost
    - Full control
  - Cons:
    - Operational complexity

- **In my project**
  - Chose managed services
  - Focus on architecture, not operations

---

### Cluster Access

- **Authentication mode**
  - Use `authentication_mode = "API_AND_CONFIG_MAP"`
  - Enables both:
    - EKS Access Entries API
    - legacy `aws-auth` ConfigMap compatibility

- **Roles**
  - **Admin**
    - Used for daily operations and break-glass access
  - **github_cicd**
    - Used by GitHub Actions for Helm add-ons and application deployments

- **Underlying access flow**
  - **IAM Role ARN**  
    → **EKS Access Entry** (register the IAM principal with the cluster)  
    → **Access Policy Association** (attach Kubernetes permissions)  
    → **Scope** (cluster-wide or namespace-scoped)  
    → **Kubernetes API access** :contentReference[oaicite:0]{index=0}

- **Admin access**
  - Admin assumes the AWS IAM role
  - Uses `aws eks update-kubeconfig --role-arn ...` to generate kubeconfig
  - `kubectl` then authenticates to EKS using that IAM role
  - Permissions are granted through the EKS access entry and associated access policy, typically with broader cluster scope for ops access. :contentReference[oaicite:1]{index=1}

- **GitHub Actions CI/CD access**
  - GitHub Actions uses **OIDC federation** to assume the `github_cicd` IAM role at runtime
  - That IAM role is registered in EKS through an **access entry**
  - Its access policy is scoped only to what the pipeline needs, ideally limited to specific namespaces rather than full cluster admin
  - The workflow then runs Helm or kubectl using the assumed role credentials. :contentReference[oaicite:2]{index=2}

---

### EKS Add-ons

- **add-ons**
  - a functional component deployed within a cluster to extend, enhance, or support its capabilities (e.g., networking, monitoring, DNS) beyond the core functionality
  - install via terraform

- **Add-ons used in my project**
  - **eks-pod-identity-agent**
    - Enables **Pod Identity** (IAM roles for pods)
    - **Secure access** from pods to AWS services without static credentials

  - **kube-proxy**
    - Handles **network routing** within the cluster
    - Maintains **iptables rules** for service communication

  - **vpc-cni**
    - Integrates Kubernetes networking with AWS VPC
    - Assigns **VPC IPs directly to pods**
    - Enables native AWS networking and security groups

  - **coredns**
    - Provides **DNS resolution** inside the cluster
    - Allows service discovery (e.g., `service.namespace.svc`)

  - **metrics-server**
    - Collects resource metrics (CPU, memory)
    - Required for **Horizontal Pod Autoscaler (HPA)**

  - **amazon-cloudwatch-observability**
    - Collects cluster-level metrics and logs
    - Enables **Container Insights** for monitoring
    - Integrated with IAM via **Pod Identity**

---

### Additional Add-ons (Non-EKS Managed)

- **External Secrets**
  - Operator that syncs AWS Secrets Manager → Kubernetes Secrets

- **External DNS**
  - Controller that maps Kubernetes resources → Route53 DNS records

- **AWS Load Balancer Controller**
  - Controller that provisions ALB/NLB from Ingress/Service

---

### External Secrets Operator

- **ESO**
  - used to integrates external secret stores (e.g., AWS Secrets Manager)
  - Fetches secrets from external APIs and syncs them into Kubernetes
  - Avoids storing sensitive data directly in the cluster
  - Install via `helm`

- **How it works (design flow)**
  1. **AWS Secrets Manager**
     - Stores secrets securely (e.g., DB password)

  2. **IAM Role + Service Account**
     - Operator uses **Pod Identity / IRSA (IAM Roles for Service Accounts)**
     - Grants permission to read secrets from AWS

  3. **SecretStore / ClusterSecretStore**
     - Defines connection to AWS Secrets Manager
     - Specifies region, service, and IAM role

  4. **ExternalSecret (CRD)**
     - Declares:
       - which secret to fetch
       - how to map it
  5. **Application Pod**
     - Consumes secret via:
       - environment variables
       - or volume mounts

- **Why this design**
  - Centralized secret management in AWS
  - No plaintext secrets in Git or manifests
  - Automatic sync and rotation support
  - Follows Kubernetes reconciliation model

- **Security benefit**
  - Least-privilege access via IAM roles
  - No static credentials in pods
  - Secrets lifecycle managed outside cluster

---

### External DNS

- **What it is**
  - A Kubernetes **controller** that automatically manages DNS records
  - Syncs Kubernetes resources (Ingress / Service) with DNS providers (e.g., Cloudflare)
  - Eliminates manual DNS configuration
  - Install via `helm`

- **How it works (design flow)**
  1. **Kubernetes Resource**
     - Ingress or Service is created
     - Annotated with hostname (e.g., `example.com`)

  2. **External DNS Controller**
     - Watches cluster resources (Ingress / Service)
     - Detects desired DNS state

  3. **IAM Role (IRSA / Pod Identity)**
     - Grants permission to update Route53

  4. **Route53**
     - External DNS creates/updates DNS records
     - Maps domain → Load Balancer endpoint

  5. **Continuous Reconciliation**
     - Keeps DNS records in sync with cluster state
     - Updates or deletes records when resources change

- **Why this design**
  - Fully automated DNS management
  - No manual Route53 updates
  - Reduces human error and operational overhead

- **Security benefit**
  - Uses IAM roles (no static credentials)
  - Can restrict permissions to specific hosted zones

- **Key distinction**
  - External DNS → manages DNS records
  - AWS Load Balancer Controller → provisions ALB/NLB

---

### AWS Load Balancer Controller

- **What it is**
  - A Kubernetes **controller** that provisions and manages AWS load balancers
  - Supports:
    - **ALB (Application Load Balancer)** → for HTTP/HTTPS (Ingress)
    - **NLB (Network Load Balancer)** → for TCP/UDP (Service)
  - Bridges Kubernetes networking with AWS infrastructure
  - Install via `helm`

- **How it works (design flow)**
  1. **Kubernetes Resource**
     - User defines:
       - `Ingress` (for ALB)

  2. **AWS Load Balancer Controller**
     - Watches these resources
     - Reads annotations (e.g., scheme, TLS, target type)

  3. **IAM Role (IRSA / Pod Identity)**
     - Grants permission to create/manage AWS resources

  4. **AWS Infrastructure Provisioned**
     - Creates:
       - ALB / NLB
       - Target Groups
       - Listeners and routing rules

  5. **Target Registration**
     - Registers pods (IP mode) or nodes (instance mode) as targets

  6. **Continuous Reconciliation**
     - Updates load balancer config when resources change
     - Deletes resources when Kubernetes objects are removed

- **Why this design**
  - Native integration between Kubernetes and AWS
  - Eliminates manual ALB/NLB provisioning
  - Supports advanced features:
    - path-based routing
    - TLS termination
    - host-based routing

- **Security considerations**
  - Use IAM roles (no static credentials)
  - Restrict permissions to required ELB actions
  - Deploy in private subnets with controlled ingress

- **Key distinction**
  - AWS Load Balancer Controller → provisions load balancer
  - External DNS → maps domain to load balancer

---
