
Details: [Deploy Authorized Keys](./../../docs/ansible-deploy-authorized-keys.md)

To run:

```bash
ansible-playbook -i <inventory-file> deploy_authorized_keys.yml --ask-pass --extra-vars='pubkey="<pubkey>"'
```

