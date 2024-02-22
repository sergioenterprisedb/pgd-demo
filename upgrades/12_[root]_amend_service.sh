#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi
sudo sed -i -e "s/${postgres_old_version}/${postgres_new_version}/g" /etc/systemd/system/postgres.service | tee -a $script_full_path/pgd.log >/dev/null

if [ $? -ne 0 ];
then
  printf "Amend service:                      ${red}KO${reset}\n"
  exit 1;
else
  printf "Amend service:                      ${green}OK${reset}\n"
fi


sudo systemctl daemon-reload
