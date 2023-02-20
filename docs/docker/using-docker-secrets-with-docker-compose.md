
# Using Docker Secrets With Docker Compose

Today I tried [to create a docker secret](https://docs.docker.com/engine/reference/commandline/secret_create/) for a Docker Swarm stack.

**Why?**  
The secret is encrypted, and you cannot read it. I’ve used environment variables before, but they are stored as plain text. You can see them if you inspect the Docker service/image.

It took me a while to figure out how to use docker secrets with a `docker-compose.yml`.

You can use Docker secrets both locally (`docker-compose up`) and for production (`docker stack deploy`).

In this post I’ll show you how to use Docker secrets with docker-compose.

## Create a secret

### “External” Create

You can manually create a secret from the command line _before_ you run your `docker-compose.yml` file.

#### 1. Create secret from `stdin`

In your terminal:

```shell
printf "some string that is your secret value" | docker secret create my_secret -
```

where `my_secret` will be the name of the Docker secret.

#### 2. Create from file

Let’s say you have file with a password. For example,`db_pass.txt` has the following content: `superSecretPassword`.

Now you can create a new secret from that file:

```shell
docker secret create my_db_pass db_pass.txt
```

where `my_db_pass` is the name of your secret.

List all available secrets:

You should see an entry with `my_db_pass`.

### Directly Inside docker-compose.yml

Inside your `docker-compose.yml` you need to create a top-level entry called `secrets`:

```yaml
version: '3'

secrets:
  psql_user:
    file: ./psql_user.txt
  psql_password:
    file: ./psql_password.txt
```

Here we have two secrets `psql_user` and `psql_password` which are created from the files with the same name.

This technique does _not_ require the initial setup with `docker secret create`.

Please remember that storing the “secret” files as plain text files on your production machine is _not_ secure. You’ll have to find a way to hide the text files.

**You need compose version 3.**

## How to Use a Secret in docker-compose.yml

Let’s say we initialize two secrets for a database:

```shell
printf "my_db_user" | docker secret create db_user -
printf "superSecretDBpassword" | docker secret create db_password -
```

First, you need the top-level declaration of all secrets.

Example:

```yaml
version: '3'

secrets:
  db_user:
    external: true
  db_password:
    external: true
```

Here we use the `external` keyword to show that we created the secrets _before_ using the `docker-compose.yml` file. You can use external secrets when Docker is in swarm mode (`docker swarm init`).

For a local setup, you might want to use the file version:

```yaml
version: '3'

secrets:
  db_user:
    file: ./my_db_user.txt
  db_password:
    file: ./my_db_pass.txt
```

Now you have to tell each service which secrets it is allowed to use.

Example:

```yaml
version: '3'

secrets:
  db_user:
    external: true
  db_password:
    external: true

services:
  postgres_db:
  image: postgres
  secrets:
    - db_user
    - db_password
```

The `postgres_db` service can now access the `db_user` and `db_password` secrets.

**How can I _use_ the secrets now?**

You can access the secrets via `/run/secret/<secret-name>` in `docker-compose.yml`.

Please note that the **secrets are stored as files**.

Example:

```yaml
version: '3'

secrets:
  db_user:
    external: true
  db_password:
    external: true

services:
  postgres_db:
  image: postgres
  secrets:
    - db_user
    - db_password
  environment:
    - POSTGRES_USER_FILE=/run/secrets/db_user
    - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
```

As you can see, we must adjust the environment variables to append a `_FILE` directive.

## Inspect a Secret

In your terminal:

```shell
docker secret inspect <name-of-secret>
```

The [command](https://docs.docker.com/engine/reference/commandline/secret_inspect/) will show some information about the secret, _but not the hidden value_.

## And Now?

Now you know how to use secrets. They are more secure than environment variables if you use them correctly.

## Further Reading

- [Manage sensitive data with Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [using-docker-secrets-with-docker-compose](https://www.rockyourcode.com/using-docker-secrets-with-docker-compose/)
- [Introduction to Docker Secrets](https://dzone.com/articles/introduction-to-docker-secrets)
- [Using Docker Secrets during Development](https://blog.mikesir87.io/2017/05/using-docker-secrets-during-development/)
- [StackOverflow: how do you manage secret values with docker-compose v3.1?](https://stackoverflow.com/questions/42139605/how-do-you-manage-secret-values-with-docker-compose-v3-1)
