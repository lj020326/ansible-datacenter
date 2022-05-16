
There are different ways to a add a new service. A new service will only be visible in permanent configuration after it has been added. To make it active in the runtime environment you need to reload firewalld.

## With firewall-config

Switch into the permanent configuration view. Click on the plus sign in the bottom of the zone list. Then enter the zone settings.

## With firewall-cmd

To add a new and empty service, use the `--new-service` altogether with the `--permanent` option:

```
firewall-cmd --permanent --new-service=myservice
```

Configure the service:

```
firewall-cmd --permanent --service=myservice --set-description=description
firewall-cmd --permanent --service=myservice --set-short=description
firewall-cmd --permanent --service=myservice --add-port=portid[-portid]/protocol
firewall-cmd --permanent --service=myservice --add-protocol=protocol
firewall-cmd --permanent --service=myservice --add-source-port=portid[-portid]/protocol
firewall-cmd --permanent --service=myservice --add-module=module
firewall-cmd --permanent --service=myservice --set-destination=ipv:address[/mask]
```

Alternatively, you can add a new service using an existing file:

```
firewall-cmd --permanent --new-service-from-file=myservice.xml
```

This adds a new service using all the settings from the file including the service name.

```
firewall-cmd --permanent --new-service-from-file=myservice.xml --name=mynewservice
```

This adds a new service using the service settings from the file. The new service will have the name `mynewservice`.

## With firewall-offline-cmd

To add a new and empty service, use the `--new-service` option:

```
firewall-offline-cmd --new-service=myservice
```

Configure the service:

```
firewall-offline-cmd --service=myservice --set-description=description
firewall-offline-cmd --service=myservice --set-short=description
firewall-offline-cmd --service=myservice --add-port=portid[-portid]/protocol
firewall-offline-cmd --service=myservice --add-protocol=protocol
firewall-offline-cmd --service=myservice --add-source-port=portid[-portid]/protocol
firewall-offline-cmd --service=myservice --add-module=module
firewall-offline-cmd --service=myservice --set-destination=ipv:address[/mask]
```

Alternatively, you can add a new service using an existing file:

```
firewall-offline-cmd --new-service-from-file=myservice.xml
```

This adds a new service using all settings from the file including the service name.

```
firewall-offline-cmd --new-service-from-file=myservice.xml --name=mynewservice
```

This adds a new service using the service settings from the file. But the new service will have the name `mynewservice`.

## Copy a file in the services directory in /etc/firewalld

As root copy the file:

```
# cp myservice.xml /etc/firewalld/services
```

After you have copied the file into `/etc/firewalld/services` it takes about 5 seconds till the new service will be visible in firewalld.

## Place a file in the services directory in /usr/lib/firewalld

This is how a package or system service could add a new service to firewalld. The benefit of placing the service into `/usr/lib/firewalld/services` is that the admin or user can modify the service and that they could go back to the original service easily by loading the defaults of the service. Then the firewalld created and modified copy in `/etc/firewalld/services` will be renamed to `<service>.xml.old` and the original service in `/usr/lib/firewalld/services` will be used again. The original service will be effective in the runtime environment only after a reload.

A package that places a service in the `/usr/lib/firewalld/services` directory should require the firewalld package or sub package that is providing the path. In an RPM based distribution that is using or that bases on the firewalld provided spec file this package is `firewalld-filesystem`.

## Reference

* https://firewalld.org/documentation/howto/add-a-service.html
