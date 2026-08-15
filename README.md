# fake-network
Containerlab network for experimenting with MAC, ARP, IP, and OSPF.

## Requirements and startup

Use this project from a WSL2 distribution with Docker Desktop WSL integration enabled. Start it from the project directory:

```sh
./start.sh
```

`start.sh` mounts the project directory into the Containerlab runner at the same absolute WSL path. This is necessary because Containerlab bind-mounts the files under `config/` into the node containers again through the Docker socket. The runner also uses `--pid=host` so it can access Docker Desktop container PIDs and their network namespaces to create the topology links.

After a failed deployment, remove the created containers and try again:

```sh
./start.sh destroy
./start.sh
```

## Topology

> MAC OUI (all nodes): `aa:c1:ab` - all subnets use `/24` prefixes

```
┌─────────────────────────────┐          ┌──────────────────────────────────┐
│           node-a            │          │               AMS                │
│                             │          │                                  │
│ eth1 :18:38:3b, 192.168.5.5 ├──────────┤  eth1 :98:62:2f, 192.168.5.1     │
└─────────────────────────────┘          │  eth2 :4b:47:be, 10.1.1.1        │
                        (192.168.5.0/24) └───────────────┬──────────────────┘
                                                         │
                                                         │  (10.1.1.0/24)
                                                         │
                                         ┌───────────────┴─────────────────────────┐
                                         │               UTR                       │
                                         │                                         │
                                         │  eth1 :56:d1:c6, 10.1.1.2               │
                                         │  eth2 :f0:89:1a, 10.1.2.1               │
                                         │  eth3 :8a:5b:24, 10.1.3.1               │
                                         └───┬────────────────────────────────┬────┘
                                             │                                │
                               (10.1.2.0/24) │                                │ (10.1.3.0/24)
                                             │                                │
                           ┌─────────────────┴─────────────┐      ┌───────────┴──────────────────┐
                           │           DEV                 │      │             APD              │
                           │                               │      │                              │
                           │  eth1 :86:37:ab, 10.1.2.2     │      │  eth1 :36:9c:06, 10.1.3.2    │
                           │  eth3 :cd:99:8b, 10.1.4.2     ├──────┤  eth2 :df:ab:67, 10.1.4.1    │
                           │  eth2 :22:b5:21, 192.168.16.1 │      │                              │
                           └──────────────┬────────────────┘      └──────────────────────────────┘
                                          │                  (10.1.4.0/24)
                         (192.68.16.0/24) │  
                                          │
                           ┌──────────────┴─────────────────┐
                           │          node-b                │
                           │                                │
                           │  eth1 :f1:00:72, 192.168.16.10 │
                           └────────────────────────────────┘
```

## Nodes and routing

`node-a` and `node-b` are Alpine endpoints. Their scripts, `config/node-a.sh` and `config/node-b.sh`, configure `192.168.5.5/24` with default gateway `192.168.5.1` and `192.168.16.10/24` with default gateway `192.168.16.1`, respectively.

`AMS`, `UTR`, `DEV`, and `APD` are FRR routers. Their respective `*-frr.conf` files configure the interface addresses shown in the diagram and OSPF area `0.0.0.0`. The OSPF router IDs are `1.1.1.1` (AMS), `2.2.2.2` (UTR), `3.3.3.3` (DEV), and `4.4.4.4` (APD). The routers provide two paths between UTR and DEV: directly over `10.1.2.0/24`, and through APD over `10.1.3.0/24` and `10.1.4.0/24`.

## Configuration files

The topology is defined in `netwerk.cabl.yaml`. For every FRR node, Containerlab mounts `config/frr-daemons` at `/etc/frr/daemons` and the node-specific configuration file at `/etc/frr/frr.conf`. `frr-daemons` is a file, not a directory, so a mount error for `/etc/frr/daemons` usually indicates an incorrect source path in the Containerlab runner. These files must use LF line endings: CRLF can cause `sharpd=no` to be read as an invalid value, making FRR try to start the unavailable `sharpd` anyway. `.gitattributes` enforces this for future checkouts.

The warnings about LLDP on the Docker bridge and missing WSL kernel modules are Docker Desktop/WSL2 limitations and do not cause a node startup failure. In this situation, the `namespace path not available` error for the Alpine nodes is a follow-up error after the FRR nodes could not be created.
