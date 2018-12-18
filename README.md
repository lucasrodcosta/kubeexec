# Kubeexec

Enables you to run commands in multiple k8s pods at once (via [itermocil](https://github.com/TomAnthony/itermocil)).  
This is the same as running `kubectl exec <pod> -c <container> <command>` in each container.

Example:

    $ kubeexec my-redis-cluster -c node redis-cli

```
.------------------.------------------.
| (0) redis cli    | (1) redis cli    |
|                  |                  |
|------------------|------------------|
| (2) redis cli    | (3) redis cli    |
|                  |                  |
.------------------.------------------.
| (4) redis cli    | (5) redis cli    |
|                  |                  |
'------------------'------------------'
```

## Installation

    $ brew tap lucasrodcosta/kubeexec && brew install kubeexec

## Usage

First find the names of all your pods:

    $ kubectl get pods

This will return a list looking something like this:

```bash
NAME                   READY     STATUS    RESTARTS   AGE
redis-cluster-aba8y    2/2       Running   0          1d
redis-cluster-gc4st    2/2       Running   0          1d
redis-cluster-m8acl    2/2       Running   0          6d
redis-cluster-s20d0    2/2       Running   0          1d
rails-v31-9pbpn        1/1       Running   0          1d
rails-v31-q74wg        1/1       Running   0          1d
```

To run the command `/bin/sh` in all pods starting with `redis-cluster`, just run the following:

    $ kubeexec redis-cluster /bin/sh

It's very easy to specify a container to run the command:

    $ kubeexec redis-cluster -c redis-node /bin/sh
