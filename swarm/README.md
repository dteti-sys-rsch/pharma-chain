# Docker Swarm Initiation

## In this folder there are 3 (temporary) docker-compose files as follows
1. docker-compose.yaml : **off-chain services**
2. hlfnet-docker-compose.yaml : **blockchain-a services (3 peer, 2 orderer)** *not yet configured on volumes*.
3. test-docker-compose.yaml : **nginx:alpine** *serves as a network check between nodes already connected or not*


## The following are the steps to set up docker swarm on a machine:

A. **Docker swarm is not configured on the machine**
1. Initialize the cluster (docker swarm) on the machine (which will be used as manager):
```
master@manager:~$ docker swarm init --advertise-addr <MANGER-IP-ADDR> --default-addr-pool <MANAGER-IP-ADDR>/<SUBNET-MASK-CIDR> --default-addr-pool-mask-length <SUBNET-MASK-CIDR>
```
So that, a token will be obtained that will be used by the worker machine to join the swarm cluster.

2. Join Other Nodes to the Cluster
```
$ worker@worker1:~$ docker swarm join --token <YOUR SWARM INIT TOKEN> <YOUR-MANAGER-IP>:2377

$ worker@worker2:~$ docker swarm join --token <YOUR SWARM INIT TOKEN> <YOUR-MANAGER-IP>:2377
```

3. With all worker machines have joined the swarm cluster, we have created our cluster. Let’s verify the nodes by typing in a Bash terminal:
```
master@manager:~$ docker node ls
```

4. List the Docker networks on manager, worker-1, and worker-2 and notice that each of them now has an overlay network called ingress and a bridge network called docker_gwbridge. Only the listing for manager is shown here:

```
master@manager:~$ docker network ls

NETWORK ID     NAME              DRIVER    SCOPE
5108c70307ef   bridge            bridge    local
2d0c53794c54   docker_gwbridge   bridge    local
29a25ea781bb   host              host      local
wamqa864seep   ingress           overlay   swarm
972ed4eeeda0   none              null      local
```

The **docker_gwbridge** connects the **ingress** network to the Docker host's network interface so that traffic can flow to and from swarm managers and workers. So that, if you create swarm services and do not specify a network, they are connected to the ingress network. It is recommended that you use separate overlay networks for each application or group of applications which will work together.

B. **Docker swarm is configured on the machine**
1. On manager node, create a new overlay network:
```
$ docker network create --driver overlay --subnet 10.10.10.0/24 --attachable <NEW-NET-NAME>
```
You don't need to create the overlay network on the other nodes, because it will be automatically created when one of those nodes starts running a service task which requires it. 
*PS: 10.10.10.0/24 just an example subnet for overlay network.*

2. Verify the new overlay network via bash command:
```
$ docker network ls

NETWORK ID     NAME              DRIVER    SCOPE
5108c70307ef   bridge            bridge    local
2d0c53794c54   docker_gwbridge   bridge    local
29a25ea781bb   host              host      local
wamqa864seep   ingress           overlay   swarm
972ed4eeeda0   none              null      local
pk0e4tzvkmg4   <NEW-NET-NAME>    overlay   swarm
```

3. After that, enter the directory that contains the docker compose, then do the following bash command:
```
$ docker stack up -c <DOCKER-COMPOSE-FILE>.yaml <STACK-NAME>
```

4. Finally, the stack containing several services has been deployed to the destination machine hostname (which is described in the compose file), then verify whether the service is running or not through this command:
```
$ docker stack ls
```
```
$ docker stack services <STACK-NAME>

or

$ docker service ls
```
```
$ docker service ps <SERVICE-NAME>
```

### Additional Note
- Dockerfile (create & build container IMAGE)
- Docker Container is a runtime instance of Docker Image.
- Docker Service can run one type of Docker Images on various containers locating on different nodes to perform the same functionality. 
- Docker Stack consists of multiple Docker Services.
- docker compose command (run containers based on settings described in a docker-compose.yaml file -- *compose an auto-defined container with code based on the compose file from existing create commands in bash such as: service create, volume create, network create, etc.*)
- images --> containers --> services --> stack

### References
- [Deploying a Docker Stack Across a Docker Swarm Using a Docker Compose File](https://towardsaws.com/deploying-a-docker-stack-across-a-docker-swarm-using-a-docker-compose-file-ddac4c0253da)
- [The Overlay Network Driver](https://medium.com/techmormo/the-overlay-network-driver-networking-in-docker-7-8d87af5eccd3)
- [How To Differentiate Between Docker Images, Containers, Stacks, Machine, Nodes and Swarms](https://betterprogramming.pub/how-to-differentiate-between-docker-images-containers-stacks-machine-nodes-and-swarms-fd5f7e34eb9f)
- [docker exec docs](https://docs.docker.com/engine/reference/commandline/exec/)