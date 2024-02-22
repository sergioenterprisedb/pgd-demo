#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

#/usr/edb/as15/bin/pg_ctl -D /opt/postgres/dataold stop
#/usr/edb/as16/bin/pg_ctl -D /opt/postgres/data stop

${pgd_old_binaries}/pg_ctl -D ${pgd_directory}/dataold stop
${pgd_old_binaries}/pg_ctl -D ${pgd_directory}/data stop
