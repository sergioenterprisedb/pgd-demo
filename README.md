# Description
In this demo I'll show how to create a Vagrant environment with EDB Postgres Distributed 5.x (PGD) installed and upgrade an EDB Postgres Advanced Server 14 (EPAS 14.x) environment to an EPAS 15.x without downtime.
This environment will contain 6 VM's:
```
> vagrant status
Current machine states:

node0                     running (virtualbox)  -> TPA node
node1                     running (virtualbox)  -> PGD Node 1
node2                     running (virtualbox)  -> PGD Node 2
node3                     running (virtualbox)  -> PGD Node 3
node4                     running (virtualbox)  -> PGD Node 4
node5                     running (virtualbox)  -> PGD Node 5
node6                     running (virtualbox)  -> Barman



                  +---------------+
             +--->|  node1 - PGD  |
             |    +---------------+
             |    +---------------+
             +--->|  node2 - PGD  |
             |    +---------------+
             |    +---------------+
             |    |  node3 - PGD  |
+---------+  |    +---------------+
|  node0  |--|
+---------+  |    +---------------+
             +--->|  node4 - PGD  |
             |    +---------------+
             |    +---------------+
             +--->|  node5 - PGD  |
             |    +---------------+
             |    +-------------------+
             +--->|  node6 -> barman  |
                  +-------------------+



```

# Prerequisites
- Vagrant
- EDB repository access
- EDB Postgres Distributed

# Start VM's
'''
./vagrant_up.sh
'''
Wait some seconds/minutes to start all VM's.

# Verify VM's are started
```
vagrant status
```

# Install EDB Postgres Distributed (EPD)
- Connect to node0
```
vagrant ssh node0

sudo -i
cd vagrant
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

# Check you PGD cluster
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
-----
 node2     | dc1_subgroup    | host=node2 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           1 | bdrdb             | 3367056606 |    1302278103 | data
 node1     | dc1_subgroup    | host=node1 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           2 | bdrdb             | 1148549230 |    1302278103 | data
 node3     | dc1_subgroup    | host=node3 port=5444 dbname=bdrdb user=enterprisedb  | ACTIVE          | ACTIVE                 |           3 | bdrdb             |  914546798 |    1302278103 | data
(3 rows)
```

# How to add a new node
In this demo, I'm installing Postgres 14.x. With PGD you can upgrade the cluster to 15.x. 

Execute this command to create a new PGD node (node4) with Postgres 15.x version:
- Connect to node0:
```
vagrant ssh node0
cd /vagrant
./02_add_new_node.sh
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

# Check you PGD cluster
Open a new terminal session and execute these commands:
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
