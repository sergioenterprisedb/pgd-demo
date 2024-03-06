#!/bin/bash

# VM list
#VBoxManage list runningvms

for i in {1..4}
do
  os=`ssh vagrant@node${i} "head -1 /etc/system-release" 2>/dev/null`
  db=`ssh vagrant@node${i} -o LogLevel=ERROR "sudo su - enterprisedb -c 'pgd show-version | tail -3  2>/dev/null'" | grep node${i} | awk '{print $3}' 2>/dev/null`
  #db=`ssh enterprisedb@node${i} psql bdrdb -c 'select version();'`
  printf "node${i}: OS version: ${os}\t Database version: ${db}\n"
done
for i in {6..6}
do
  os=`ssh vagrant@node${i} "head -1 /etc/system-release" 2>/dev/null`
  db=`ssh vagrant@node${i} -o LogLevel=ERROR "sudo su - enterprisedb -c 'pgd show-version | tail -3  2>/dev/null'" | grep node${i} | awk '{print $3}'`
  #db=`ssh enterprisedb@node${i} psql bdrdb -c 'select version();'`
  printf "node${i}: OS version: ${os}\t Database version: ${db}\n"
done
