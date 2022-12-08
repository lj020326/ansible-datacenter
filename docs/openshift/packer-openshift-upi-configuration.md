# Overview 

Sample Packer initialization of vSphere UPI for OCP 4. The [`rhcos.json`](rhcos.json) file includes the bootstrap and *schedulable* control plane nodes, but no workers. You will be required to shutdown the nodes once `openshift-install` is complete so the packer build exits gracefully. This is has been tested with **OpenShift 4.6.9** using the new(ish) live ISO and **vCenter 6.5** + **vCenter 7.0**

# Usage

  1. Set environment variable with password to access vCenter (or use Vault) for secure variables
     ````
     export VSPHERE_PASS="YourP@ssword"
     ````
  2. Update the variables in `rhcos.json` or pass as supplemental `-var` options as shown below
  3. Execute Packer to build the VM, which will shutdown when complete
     ```
     packer build rhcos.json
     ``` 
  
## Reference

* https://github.com/liveaverage/packer-ocp4-vsphere-upi
