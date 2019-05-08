# Wilson

## SSH keys

You can pass in a key from the host like so:

```
docker build --build-arg SSH_KEY="$(< ~/.ssh/wilson/id_rsa)" -t wilson .
```

## Getting into the container

You can SSH into the container like so:

```
docker exec  --user jfree -it 085bb64f3f7a /bin/bash
```