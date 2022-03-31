
Using Docker Secrets in your Environment Variables
===

If you want to use Docker containers in production, chances are you’ll want to store your credentials in a secure way. A way to do that for Docker Swarm is to use Docker secrets.

A secret can be defined easily enough on your swarm manager using the following:

```
echo "mysupersecurepassword" | docker secret create my_password_secret -
```

Now, you will probably want to reference secrets from your environment variables, but that is unfortunately not supported yet. In order to do just that, there is a workaround implemented in the official docker [Mysql](https://github.com/docker-library/mysql/blob/master/5.7/docker-entrypoint.sh) and [WordPress](https://github.com/docker-library/wordpress/blob/master/docker-entrypoint.sh) containers.

Secrets are accessible from the containers that have access to them by using the file path /run/secrets/my\_password\_secret, so what you can do, is add another environment variable to your docker-compose, having a custom name (appending \_FILE for example)

```
version: '3.3'secrets:  my_password_secret:    external: trueservices:  db:    image: mysql:5.7    environment:      MYSQL_PASSWORD_FILE: /run/secrets/my_password_secret    secrets:      - my_password_secret
```

And in your container entrypoint, call the following function for each environment variable you have set up.

```
#!/usr/bin/env bashset -efile_env() {   local var="$1"   local fileVar="${var}_FILE"   local def="${2:-}"   if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then      echo >&2 "error: both $var and $fileVar are set (but are exclusive)"      exit 1   fi   local val="$def"   if [ "${!var:-}" ]; then      val="${!var}"   elif [ "${!fileVar:-}" ]; then      val="$(< "${!fileVar}")"   fi   export "$var"="$val"   unset "$fileVar"}file_env "MYSQL_PASSWORD"
```

This will export the value stored in the secret to the correct environment variable (**MYSQL\_PASSWORD** in this case)

## References

* https://docs.docker.com/engine/swarm/configs/
* https://medium.com/@adrian.gheorghe.dev/using-docker-secrets-in-your-environment-variables-7a0609659aab
* https://stackoverflow.com/questions/48094850/docker-stack-setting-environment-variable-from-secrets
* https://pythonspeed.com/articles/build-secrets-docker-compose/
* 