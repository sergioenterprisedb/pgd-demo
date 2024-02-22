#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

pgd show-nodes | tee -a $script_full_path/pgd.log >/dev/null
pgd show-version | tee -a $script_full_path/pgd.log >/dev/null
pgd show-raft | tee -a $script_full_path/pgd.log >/dev/null
pgd show-replslots | tee -a $script_full_path/pgd.log >/dev/null

