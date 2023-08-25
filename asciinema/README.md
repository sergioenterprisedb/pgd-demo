# Asciinema demos
Four demos exists that show:
- Vagrant VM's deployment
- EDB Postgres Distributed (PGD) deployment with EDB Postgres Advanced Server 14.x
- PGD check nodes
- Add a new EDB Postgres Advanced Server 15.x node in the PGD cluster

# How to run asciinema
## Prerequisites
- Install [asciinema](https://asciinema.org/docs/installation)

## Run asciinema macros
- To run the asciinema macros, execute these commands:
```
asciinema play 01_vagrant_up.cast -i 0.1
asciinema play 02_deployment.cast -i 0.1
asciinema play 03_check_pgd_deployment.cast -i 0.1
asciinema play 04_add_cluster_node.cast -i 0.1
```

