# EDB Postgres Distributed deployments
In this demo I'll show how deploy and upgrade a [EDB Postgres Distributed](https://www.enterprisedb.com/products/edb-postgres-distributed) 5.x (PGD) environment with different PostgreSQL and OS versions in a local environment with [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org).
*With this solution, it will not be necessary to provision resources in a cloud provider.*

Steps:
- Deploy VM's (with Vagrant and VirtualBox)
  - 3 nodes with *Rocky Linux 8*
- Install TPA [Trusted Postgres Architect](https://www.enterprisedb.com/docs/tpa/latest/)
- Deploy with TPA 3 PGD nodes (*PostgreSQL 14.x*)
- Add with TPA a new PGD node (*Rocky Linux 9.x* and *PostgreSQL 15.x*)
- Upgrade PGD cluster nodes (1,2 and 3) from PostgreSQL 14.x to 15.x in Rocky Linux 8.x

You can find the EDB Postgres Distributed documentation [here](https://www.enterprisedb.com/docs/pgd/latest/).

This environment will contain 7 VM's:
```

                               ┌─────────────────────────┐
                          ┌───►│  node1 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          │───►│  node2 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          │───►│  node3 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
┌──────────────────────┐  │    └─────────────────────────┘
│  node0 - TPA         │──│
│  OS: Rocky Linux 8.x │  │
└──────────────────────┘  │    ┌─────────────────────────┐
                          │───►│  node4 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          │───►│  node5 - PGD - Optional │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          └───►│  node6 -> barman        │
                               │  OS: Rocky Linux 8.x    │
                               └─────────────────────────┘

```

# Prerequisites
- [VirtualBox](https://www.virtualbox.org)
- [Vagrant](https://www.vagrantup.com)
- EDB repository access. If don't have an EDB user you can register [here](https://www.enterprisedb.com/accounts/register).

# Start VM's
```
./vagrant_up.sh
```
Wait some seconds/minutes to start all VM's.

# Verify VM's are started
```
vagrant status
Current machine states:

node0                     running (virtualbox)  -> TPA node
node1                     running (virtualbox)  -> PGD Node 1
node2                     running (virtualbox)  -> PGD Node 2
node3                     running (virtualbox)  -> PGD Node 3
node4                     running (virtualbox)  -> PGD Node 4
node5                     running (virtualbox)  -> PGD Node 5 (not used in this demo but ready for new PGD nodes if necessary)
node6                     running (virtualbox)  -> Barman
```

# Deploy EDB Postgres Distributed (PGD)
Connect to node0

```
vagrant ssh node0
```
This step will use TPA [Trusted Postgres Architect](https://www.enterprisedb.com/docs/tpa/latest/) to deploy EDB Postgres Distributed.

Connect as root:
```
sudo -i
```
Setup this variable with your EDB repo credential value.
```
export repo_credentials=<your_repo_token>
```
Deploy PGD.
```
cd /vagrant
./01_install_pgd.sh
```
Result:
```
...
PLAY RECAP ***************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node1                      : ok=392  changed=112  unreachable=0    failed=0    skipped=238  rescued=0    ignored=1
node2                      : ok=373  changed=93   unreachable=0    failed=0    skipped=237  rescued=0    ignored=0
node3                      : ok=346  changed=85   unreachable=0    failed=0    skipped=238  rescued=0    ignored=0
node6                      : ok=186  changed=35   unreachable=0    failed=0    skipped=166  rescued=0    ignored=0


real	15m58.005s
user	4m50.743s
sys	1m42.639s
How to connect?
sudo su - enterprisedb
psql bdrdb
```

# Check your PGD cluster
Open a new terminal session and execute these commands:
```
vagrant ssh node1

[vagrant@node1 ~]$ sudo su - enterprisedb
Last login: Thu Aug 24 10:45:34 UTC 2023 on pts/0
enterprisedb@node1:~ $ psql bdrdb
psql (14.9.0, server 14.9.0)
Type "help" for help.

bdrdb=# select * from bdr.node_summary ;
 node_name | node_group_name |                  interface_connstr                   | peer_state_name | peer_target_state_name | node_seq_id | node_local_dbname |  node_id   | node_group_id | node_kind_
name
-----------+-----------------+------------------------------------------------------+-----------------+------------------------+-------------+-------------------+------------+---------------+-----------
 node2     | dc1_subgroup    | host=node2 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           1 | bdrdb             | 3367056606 |    1302278103 | data
 node1     | dc1_subgroup    | host=node1 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           2 | bdrdb             | 1148549230 |    1302278103 | data
 node3     | dc1_subgroup    | host=node3 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           3 | bdrdb             |  914546798 |    1302278103 | data
(3 rows)
```
# Add a new node
Execute this command to create a new PGD node (node4) with Postgres 15.x and Rocky Linux 9 versions:
Connect to node0:
```
vagrant ssh node0
sudo -i
cd /vagrant
./02_add_new_node.sh 4
...
PLAY RECAP *************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node1                      : ok=372  changed=10   unreachable=0    failed=0    skipped=250  rescued=0    ignored=0
node2                      : ok=330  changed=8    unreachable=0    failed=0    skipped=246  rescued=0    ignored=0
node3                      : ok=330  changed=8    unreachable=0    failed=0    skipped=246  rescued=0    ignored=0
node4                      : ok=347  changed=83   unreachable=0    failed=0    skipped=237  rescued=0    ignored=0
node6                      : ok=176  changed=2    unreachable=0    failed=0    skipped=170  rescued=0    ignored=0


real	21m14.197s
user	9m23.203s
sys	2m39.701s
```
At this moment, node4 has been added with an EPAS 15.x

# Verify VM's OS version
Connect to node0
```
vagrant ssh node0
cd /vagrant/
./os_version.sh
node1: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node2: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node3: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node6: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
```

# Upgrade Nodes
Connect to the node you want to upgrade (ex: node1)
```
vagrant ssh node0
```
Verify ./upgrade/config.sh file to select the right Postgres version
Execute command:
```
ssh vagrant@node1 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh'
```

# Check you PGD cluster
Open a new terminal session and execute these commands. Check the node4 status (CATCHUP, PROMOTING,ACTIVE):
```
vagrant ssh node1

[vagrant@node1 ~]$ sudo su - enterprisedb
Last login: Thu Aug 24 10:45:34 UTC 2023 on pts/0
enterprisedb@node1:~ $ psql bdrdb
psql (14.9.0, server 14.9.0)
Type "help" for help.

bdrdb=# select * from bdr.node_summary ;

 node_name | node_group_name |                  interface_connstr                   | peer_state_name | peer_target_state_name | node_seq_id | node_local_dbname |  node_id   | node_group_id | node_kind_name
-----------+-----------------+------------------------------------------------------+-----------------+------------------------+-------------+-------------------+------------+---------------+----------------
 node2     | dc1_subgroup    | host=node2 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           1 | bdrdb             | 3367056606 |    1302278103 | data
 node1     | dc1_subgroup    | host=node1 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           2 | bdrdb             | 1148549230 |    1302278103 | data
 node3     | dc1_subgroup    | host=node3 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           3 | bdrdb             |  914546798 |    1302278103 | data
(3 rows)

bdrdb=# \watch 5;
 ...
 ...
 ...
 node_name | node_group_name |                  interface_connstr                   | peer_state_name | peer_target_state_name | node_seq_id | node_local_dbname |  node_id   | node_group_id | node_kind_name
-----------+-----------------+------------------------------------------------------+-----------------+------------------------+-------------+-------------------+------------+---------------+----------------
 node2     | dc1_subgroup    | host=node2 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           1 | bdrdb             | 3367056606 |    1302278103 | data
 node1     | dc1_subgroup    | host=node1 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           2 | bdrdb             | 1148549230 |    1302278103 | data
 node3     | dc1_subgroup    | host=node3 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           3 | bdrdb             |  914546798 |    1302278103 | data
 node4     | dc1_subgroup    | host=node4 port=5444 dbname=bdrdb user=enterprisedb  | CATCHUP         | ACTIVE                 |           4 | bdrdb             |  759086513 |    1302278103 | data
(4 rows)

 node_name | node_group_name |                  interface_connstr                   | peer_state_name | peer_target_state_name | node_seq_id | node_local_dbname |  node_id   | node_group_id | node_kind_name
-----------+-----------------+------------------------------------------------------+-----------------+------------------------+-------------+-------------------+------------+---------------+----------------
 node2     | dc1_subgroup    | host=node2 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           1 | bdrdb             | 3367056606 |    1302278103 | data
 node1     | dc1_subgroup    | host=node1 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           2 | bdrdb             | 1148549230 |    1302278103 | data
 node3     | dc1_subgroup    | host=node3 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           3 | bdrdb             |  914546798 |    1302278103 | data
 node4     | dc1_subgroup    | host=node4 port=5444 dbname=bdrdb user=enterprisedb  | PROMOTING       | ACTIVE                 |           4 | bdrdb             |  759086513 |    1302278103 | data
(4 rows)

 node_name | node_group_name |                  interface_connstr                   | peer_state_name | peer_target_state_name | node_seq_id | node_local_dbname |  node_id   | node_group_id | node_kind_name
-----------+-----------------+------------------------------------------------------+-----------------+------------------------+-------------+-------------------+------------+---------------+----------------
 node2     | dc1_subgroup    | host=node2 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           1 | bdrdb             | 3367056606 |    1302278103 | data
 node1     | dc1_subgroup    | host=node1 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           2 | bdrdb             | 1148549230 |    1302278103 | data
 node3     | dc1_subgroup    | host=node3 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           3 | bdrdb             |  914546798 |    1302278103 | data
 node4     | dc1_subgroup    | host=node4 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           4 | bdrdb             |  759086513 |    1302278103 | data
(4 rows)

```

# Time to prepare the platform
- Around 2 minutes to start VM's
- Around 10 minutes to deploy PGD in VM's
- Around 10 minutes to add a new node

# How to destroy the environment
This command will destroy all the VM's created by vagrant (node0 to node6).
```
./vagrant_destroy.sh
```
You can destroy one by one if necessary:
```
vagrant destroy -f node5
```
