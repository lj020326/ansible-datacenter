
```shell
$ cat ~/config/pfsense-api.json
{
    "client_id": "api_client_id_here",
    "client_token": "api_client_token_here",
    "mode": "api_token",
    "hostname": "pfsense.johnson.int",
    "verify": "false"
}

$ python pfsense_api_client.py get-gateway-status
$ python pfsense_api_client.py get-interface-status
$ python pfsense_api_client.py get-system-api-version
$ python pfsense_api_client.py get-system-status
$ python pfsense_api_client.py list-leases
$ python pfsense_api_client.py get-configuration-history-status-log
$ python pfsense_api_client.py get-configuration-history-status-log --find firewall
$ python pfsense_api_client.py get-configuration-history-status-log --find override

$ python pfsense_api_client.py get-service-unbound-access-list
$ python pfsense_api_client.py get-service-unbound-host-override --find example.int
$ python pfsense_api_client.py get-service-unbound-host-override --debug
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int 1.2.3.4

$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int 1.2.3.4
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int 1.2.3.4 $ True
$ python pfsense_api_client.py add-service-unbound-host-override --help
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int $ "1.2.3.4,2.3.4.5"
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int $ "1.2.3.4,2.3.4.5" True
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int 1.2.3.4
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int 1.2.3.4 True
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int $ 1.2.3.4,2.3.4.5
$ python pfsense_api_client.py add-service-unbound-host-override foobar example.int [1.2.3.4]
$ python pfsense_api_client.py delete-service-unbound-host-overrides foobar example.int 1.2.3.4
$ python pfsense_api_client.py delete-service-unbound-host-overrides foobar example.int $ 1.2.3.4 ---apply
$ python pfsense_api_client.py delete-service-unbound-host-overrides foobar example.int $ 1.2.3.4 --apply
$ python pfsense_api_client.py delete-service-unbound-host-overrides foobar example.int $ 1.2.3.4 True
$ python pfsense_api_client.py delete-service-unbound-host-overrides-by-hostname wiki.example.$ int --apply --debug
$ python pfsense_api_client.py delete-service-unbound-host-overrides-by-hostname wiki.$ example.int
$ python pfsense_api_client.py delete-service-unbound-host-overrides-by-hostname wiki.$ example.int --apply
$ python pfsense_api_client.py dig-host-ip-list wiki.example.int ns1.example.int
$ python pfsense_api_client.py dns-resolve-host-ip-list --debug wiki.example.int ns1.example.$ int
$ python pfsense_api_client.py dns-resolve-host-ip-list wiki.example.int 172.21.1.16 --debug
$ python pfsense_api_client.py dns-resolve-host-ip-list wiki.example.int ns1.example.int
$ python pfsense_api_client.py dns-resolve-host-ip-list wiki.example.int ns1.example.int $ --debug
$ python pfsense_api_client.py get-configuration-history-status-log
$ python pfsense_api_client.py get-configuration-history-status-log --find firewall
$ python pfsense_api_client.py get-configuration-history-status-log --find override
$ python pfsense_api_client.py get-gateway-status
$ python pfsense_api_client.py get-interface-status
$ python pfsense_api_client.py get-service-unbound-access-list
$ python pfsense_api_client.py get-service-unbound-host-override
$ python pfsense_api_client.py get-service-unbound-host-overrides --debug
$ python pfsense_api_client.py get-service-unbound-host-overrides --find "foobar example.int $ 1.2.3.4"
$ python pfsense_api_client.py get-service-unbound-host-overrides --find "foobar"
$ python pfsense_api_client.py get-service-unbound-host-overrides --find foobar
$ python pfsense_api_client.py get-service-unbound-host-overrides-by-hostname wiki.example.int --debug
$ python pfsense_api_client.py get-service-unbound-host-overrides-by-hostname wiki.example.int
$ python pfsense_api_client.py get-system-api-version
$ python pfsense_api_client.py get-system-status
$ python pfsense_api_client.py list-leases
$ python pfsense_api_client.py sync-host-ip-list wiki.example.int ns1.example.int --apply
$ python pfsense_api_client.py sync-host-ip-list wiki.example.int ns1.example.int --debug
$ python pfsense_api_client.py sync-host-ip-list wiki.example.int ns1.example.int --debug $ --apply
$ python pfsense_api_client.py sync-host-ip-list wiki.example.int ns1.example.int True --debug
$ python pfsense_api_client.py sync-host-ip-list wiki.example.int ns1.example.int True $ --debug --apply

```
