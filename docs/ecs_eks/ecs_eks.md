# Automated Architecture Benchmark - ECS vs EKS

[Back](../../README.md)

- [Automated Architecture Benchmark - ECS vs EKS](#automated-architecture-benchmark---ecs-vs-eks)
  - [Key Results](#key-results)
  - [ECS vs EKS](#ecs-vs-eks)
    - [1. Scaling Behavior](#1-scaling-behavior)
    - [2. Scaling Implementation](#2-scaling-implementation)
    - [3. Consistent Pattern Across ECS and EKS](#3-consistent-pattern-across-ecs-and-eks)
  - [Comparison and Trade-offs](#comparison-and-trade-offs)
  - [Takeaways](#takeaways)
    - [Key Insight](#key-insight)
    - [When to Choose ECS](#when-to-choose-ecs)
    - [When to Choose EKS](#when-to-choose-eks)

---

## Key Results

| Platform | Architecture | Peak RPS | P95 Latency | Resource Usage | DB CPU |
| -------- | ------------ | -------- | ----------- | -------------- | ------ |
| ECS      | Scale        | 1000     | 70ms        | 18 Tasks       | 48.6%  |
| ECS      | Redis        | 1000     | 75ms        | 16 Tasks       | 34.9%  |
| ECS      | Kafka        | 1000     | 25ms        | 10 Tasks       | 15.8%  |
| EKS      | Scale        | 1000     | 98ms        | 7 Pods         | 42.1%  |
| EKS      | Redis        | 1000     | 102ms       | 5 Pods         | 35.3%  |
| EKS      | Kafka        | 1000     | 92ms        | 3 Pods         | 10.5%  |

---

## ECS vs EKS

### 1. Scaling Behavior

- Same baseline: **1 vCPU per workload**
  - ECS → requires **more tasks** to handle load
  - EKS → uses **fewer pods**, but scales **nodes dynamically**

- **Key difference is driven by scaling strategy:**
  - ECS Auto Scaling → target CPU **25%**
  - EKS HPA → target CPU **40%**

---

### 2. Scaling Implementation

- **ECS**
  - Service Auto Scaling Policy
  - Common types:
    - `Target Tracking`
    - `Step Scaling`
    - `Predictive Scaling`
  - **Simpler and tightly integrated with AWS**

- **EKS**
  - Two-layer scaling: **pod + infrastructure**
    - **Application layer**: `HPA (Horizontal Pod Autoscaler)`
    - **Infrastructure layer**: `Karpenter`
  - **More flexible, but higher operational complexity**

---

### 3. Consistent Pattern Across ECS and EKS

Across both platforms, the same architectural behavior appears:

- **Scale**
  - Handles load via compute increase
  - → shifts bottleneck to **database**

- **Redis**
  - Reduces redundant queries
  - → lowers DB pressure and improves efficiency

- **Kafka**
  - Decouples request from processing
  - → lowest latency, lowest resource usage, lowest DB load

> **Conclusion:**  
> Platform affects _how the system scale_,  
> but **architecture determines how the system behaves under load**

---

## Comparison and Trade-offs

| Aspect      | ECS        | EKS                                         |
| ----------- | ---------- | ------------------------------------------- |
| Scaling     | Task-based | Pod + Node (HPA + Karpenter)                |
| Complexity  | Lower      | Higher                                      |
| Control     | Limited    | High flexibility                            |
| Integration | AWS-native | Requires additional setup (cluster + infra) |

---

## Takeaways

### Key Insight

> **Architecture > Platform (for performance and efficiency)**

- `Scaling` alone shifts bottlenecks downstream (typically to the database)
- `Caching` and `async design` fundamentally improve system behavior
- This holds true across both `ECS` and `EKS`

---

### When to Choose ECS

- Simpler architecture and **faster setup**
- **Lower operational overhead** preferred
- Smaller teams or limited Kubernetes experience
- Standard microservices with predictable scaling needs

---

### When to Choose EKS

- Need for **fine-grained control** over scaling and infrastructure
- Advanced workloads (event-driven, platform engineering, multi-tenant systems)
- Integration with Kubernetes ecosystem (Helm, Operators, GitOps)
- Long-term scalability and flexibility requirements
