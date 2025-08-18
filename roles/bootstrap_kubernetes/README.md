# bootstrap_kubernetes

## Important Considerations

**Kubernetes Version**: This role pins the Kubernetes version to 1.33.4-1.1 (latest patch as of August 2025, EOL ~June 2026). Check https://kubernetes.io/releases/ for the latest stable version compatible with kubeadm and kubelet. Ubuntu 24.04 ("Noble Numbat") uses modern APT keyrings.

**GPG Key Handling**: The role downloads the Kubernetes signing key (ID: 234654DA9A296436, valid until December 2026) and converts it to binary format. If "NO_PUBKEY" errors occur, verify:
- Key file exists: `ls -l /etc/apt/keyrings/kubernetes-apt-keyring.gpg` (should be 0644).
- Key integrity: `gpg --keyring /etc/apt/keyrings/kubernetes-apt-keyring.gpg --list-keys 234654DA9A296436`.
- Repository file: `cat /etc/apt/sources.list.d/kubernetes.list` (should be `deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /`).
- Manual fix: `curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg`.

**Kubernetes Admin User**: The role creates a user (default: `kubernetes`) for managing Kubernetes configurations. Override the username by setting `bootstrap_kubernetes__user` in your inventory or playbook vars. For example:
  ```yaml
  bootstrap_kubernetes__user: "k8sadmin"
  ```
  The role ensures the user exists with a home directory and bash shell.

**CNI Plugin**: Installs Calico as the CNI plugin. For alternatives (e.g., Flannel, Cilium), modify the `Install Calico CNI` task.

**Production Readiness**: This sets up a single-node cluster for testing/development. For production, use a multi-node setup with monitoring, storage, and networking.

**GPU Drivers**: This role does not install NVIDIA GPU drivers. Use a separate role for GPU support and the NVIDIA Container Toolkit.

**Troubleshooting**:
- If "Final apt update" fails with "NO_PUBKEY":
  - Check `ansible.log` for details (e.g., `NO_PUBKEY`, 403 Forbidden, or timeout).
  - Verify key file: `ls -l /etc/apt/keyrings/kubernetes-apt-keyring.gpg`.
  - Check key content: `gpg --keyring /etc/apt/keyrings/kubernetes-apt-keyring.gpg --list-keys 234654DA9A296436`.
  - Inspect repository: `cat /etc/apt/sources.list.d/kubernetes.list`.
  - Manually re-download key: `curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg`.
  - Add key to APT: `sudo apt-key add /etc/apt/keyrings/kubernetes-apt-keyring.asc` (deprecated but can help diagnose).
- Test connectivity: `curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key`.
- Run playbook with verbose output: `ansible-playbook -i inventory/PROD site.yml -vvv`.
- Check APT config: `cat /etc/apt/apt.conf.d/*` for conflicting settings.
- Verify containerd configuration: `cat /etc/containerd/config.toml | grep -A 5 '\[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options\]'` (should include `SystemdCgroup = true`).
- Verify user creation: `id {{ bootstrap_kubernetes__user }}` to ensure the user exists.