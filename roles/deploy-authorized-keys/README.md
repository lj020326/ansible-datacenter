
Ref: [Deploy Authorized Keys](https://medium.com/@visualskyrim/ansible-playbook-deploy-the-public-key-to-remote-hosts-da3f3b4b5481)

To run:

```bash
ansible-playbook -i <inventory-file> deploy_authorized_keys.yml --ask-pass --extra-vars='pubkey="<pubkey>"'
```

