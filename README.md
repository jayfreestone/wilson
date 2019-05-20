# Wilson 🏉

## Creating the infrastructure

Presuming the cluster is set up, and `kubectl` configured, we need to create a secret containing our ssh key (folder containing both public and private keys):

```
kubectl create secret generic ssh-key --from-file=~/.ssh/wilson
```

Then create the user-files ConfigMap:

```
kubectl create configmap user --from-file=configmap-files
```

Then the ReplicaSet:

```
kubectl create -f kubernetes/wilson-rs.yml
```

And the two access services, replacing the load balancer IP with a statically assigned one:

```
cat kubernetes/wilson-ssh-sv.yml | sed s/\$WILSON_STATIC_LOAD_BALANCER_IP/0.00.0.0/ | kubectl create -f -
cat kubernetes/wilson-mosh-sv.yml | sed s/\$WILSON_STATIC_LOAD_BALANCER_IP/0.00.0.0/ | kubectl create -f -
```

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
