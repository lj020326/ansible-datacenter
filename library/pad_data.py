from ansible.module_utils.basic import AnsibleModule

# source: https://stackoverflow.com/questions/47018363/ansible-updating-values-in-a-list-of-dictionaries

## This function pads the ip addresses (ip_addresses, nat_destination_addresses and nat_source_address) and ports.
## The ports should have a length of five characters with zeroes at the beginning (2000 becomes 02000 and 2000-5600 becomes 02000-05600)
## and the ip addresses should have three characters for each subsection (18.18.18.18 becomes 018.018.018.018).

def pad_addr(addr):
    return '.'.join('%03d' % int(x) for x in addr.split('.'))

def main():
    module_args = dict(
        data=dict(type='list', required=True),
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    data = module.params['data']

    for d in data:
        if 'ip_addresses' in d:
            d['ip_addresses'] = [pad_addr(x) for x in d['ip_addresses']]

        if 'nat_destination_addresses' in d:
            for dest in d['nat_destination_addresses']:
                dest['host'] = pad_addr(dest['host'])
                dest['destination'] = pad_addr(dest['destination'])

        if 'nat_source_address' in d:
            d['nat_source_address'] = pad_addr(d['nat_source_address'])

        if 'applications' in d:
            for service in d['applications']:
                service['port'] = '%05d' % service['port']

    module.exit_json(changed=False,
                     result=data)

if __name__ == '__main__':
    main()