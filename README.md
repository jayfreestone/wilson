# Wilson

## Getting into the container

You can SSH into the container like so:

```
docker exec --user jfree -it 085bb64f3f7a /bin/bash
```

## Connecting via SSH

```
ssh -p 3222 jfree@<STATIC_IP> -i <PATH_TO_WILSON_KEY>
```

Mosh:

```
mosh -p 60001 --no-init --ssh="ssh -o StrictHostKeyChecking=no -p 3222 -i <PATH_TO_WILSON_KEY>" jfree@<STATIC_IP>
```
