
# How to use pfSense api

## Install dependency

### Debugging api

### Basic Auth
If using proxy to debug api
We use proxyman.  Start proxyman listening on localhost port 9090.

Then to test generate bearer token, run the curl test command using the proxy:
```shell
curl -k --proxy localhost:9090 -u USERNAME:PASSWORD -X POST https://pfsense.johnson.int/api/v1/access_token
```

### API Token Auth

If using the api_token method, generate token in System > API.

Then run the curl test:
```shell
curl -k --proxy localhost:9090 -H "Authorization: CLIENT_ID_HERE CLIENT_TOKEN_HERE" -X GET https://pfsense.johnson.int/api/v1/system/arp 
```


## Reference

- https://github.com/jaredhendrickson13/pfsense-api
