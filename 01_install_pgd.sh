#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

export credentials=$repo_credentials

# bat installation
rpm -ivh http://repo.openfusion.net/centos7-x86_64/bat-0.7.0-1.of.el7.x86_64.rpm 


# PGD 5.x
curl -1sLf "https://downloads.enterprisedb.com/$credentials/postgres_distributed/setup.rpm.sh" | sudo -E bash

yum -y install wget chrony tpaexec tpaexec-deps
# Config file: /etc/chrony.conf
systemctl enable --now chronyd
chronyc sources

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
EOF
source ~/.bash_profile

# Install dependencies
tpaexec setup

# Test
tpaexec selftest

mkdir ~/clusters

ip=192.168.1
cat > ~/clusters/hostnames.txt << EOF
node1 $ip.11
node2 $ip.12
node3 $ip.13
node4 $ip.14
node5 $ip.15
node6 $ip.16
EOF

tpaexec configure ~/clusters/speedy \
    --architecture PGD-Always-ON \
    --redwood \
    --platform bare \
    --hostnames-from ~/clusters/hostnames.txt \
    --edb-postgres-advanced 14 \
    --no-git \
    --location-names dc1 \
    --pgd-proxy-routing global \
    --hostnames-unsorted

# Modify pg_hba.conf
cp ~/clusters/speedy/config.yml ~/clusters/speedy/config.yml.1

# Replace barman node4 to node6
sed -i 's/node4/node6/' ~/clusters/speedy/config.yml
sed -i 's/node: 4/node: 6/' ~/clusters/speedy/config.yml
sed -i 's/192.168.1.14/192.168.1.16/' ~/clusters/speedy/config.yml

# Provision
tpaexec provision ~/clusters/speedy

# Copying ssh keys
rm -f ~/clusters/speedy/id_speedy.pub
rm -f ~/clusters/speedy/id_speedy
cp ~/.ssh/id_rsa.pub ~/clusters/speedy/id_speedy.pub
cp ~/.ssh/id_rsa ~/clusters/speedy/id_speedy

# Ping
tpaexec ping ~/clusters/speedy

# Deploy
tpaexec deploy ~/clusters/speedy

# Change app password
#echo -e "app\n"  | tpaexec store-password ~/clusters/speedy app

# Deprovision
#tpaexec deprovision ~/clusters/speedy

echo "How to connect?"
echo "sudo su - enterprisedb"
echo "psql bdrdb"
