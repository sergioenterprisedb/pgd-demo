#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

sudo ~enterprisedb/delete_old_cluster.sh | tee -a $script_full_path/pgd.log >/dev/null

if [ $? -ne 0 ];
then
  printf "Delete old cluster:                 ${red}KO${reset}\n"
  exit 1;
else
  printf "Delete old cluster:                 ${green}OK${reset}\n"
fi
