
# bootstrap_aibrix

## Key Configuration Variables:

- bootstrap_aibrix__version: AIBrix version to install (default: v0.3.0)
- bootstrap_aibrix__gpu_enabled: Enable GPU support
- bootstrap_aibrix__gpu_type: GPU type (v100, a100, h100, t4)
- bootstrap_aibrix__autoscaling_enabled: Enable autoscaling
- bootstrap_aibrix__monitoring_enabled: Enable Prometheus monitoring
- bootstrap_aibrix__ingress_enabled: Enable external access via ingress

The role handles the complete lifecycle of AIBrix deployment, from installing dependencies to configuring advanced features like distributed inference and GPU management, making it suitable for production LLM deployments on Kubernetes.

## Key Features:

- **Complete Installation Process**: Installs both AIBrix dependencies and core components using the stable v0.3.0 release
- **Core Components**:

    **Gateway and Routing**: Manages traffic across multiple LLM models and replicas
    **Runtime Management**: Handles model loading, caching, and execution
    **Autoscaling**: Dynamically scales based on demand
    **Distributed Inference**: Supports multi-node LLM deployment
    **GPU Management**: Includes GPU failure detection and resource allocation

- **Configuration Options**:

  * Customizable resource limits and requests
  * Autoscaling parameters (min/max replicas, CPU targets)
  * GPU configuration (type, count, failure detection)
  * Model caching and distributed KV cache settings
  * Monitoring and ingress setup

- **Production-Ready Features**:

  * Health checks and readiness probes
  * Prometheus monitoring integration
  * Ingress configuration with TLS support
  * RBAC and network policies support
  * Rolling update capabilities

## References

- https://github.com/vllm-project/aibrix
