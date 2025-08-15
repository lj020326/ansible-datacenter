
# bootstrap_kubernetes

## Important Considerations

**Kubernetes Version**: I've pinned the Kubernetes version to 1.28.16-1.1 for stability. Always check the latest stable version that is compatible with your kubeadm and kubelet versions. Newer Ubuntu versions (like 24.04 "Noble Numbat") might have slightly different APT repository configurations or package versions, so always verify against official Kubernetes documentation for the precise repository setup for your specific Ubuntu version.

**CNI Plugin**: This role installs Calico as the CNI (Container Network Interface) plugin, which is a common choice. If you have a different preference (e.g., Flannel, Cilium), you'll need to adjust the kubectl apply command.

**Production Readiness**: This is a basic setup for a single-node cluster. For production environments, you'd typically want a multi-node cluster, more robust monitoring, persistent storage solutions, and advanced networking.

**GPU Drivers**: This role does not install NVIDIA GPU drivers. If your AIBrix setup will leverage GPUs, you'll need a separate role or manual steps to install the appropriate NVIDIA drivers and NVIDIA Container Toolkit on your Ubuntu server before deploying AIBrix.
