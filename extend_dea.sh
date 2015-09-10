#!/bin/bash

if [ $# -lt 6 ] ; then
    echo -e "\e[1;33m!!!USEAGE: extend_dea.sh [REMOTE_IP] [PASSWD] [NATS_ADDR] [ETCD_ADDR] [SYS_PASSWORD] [DOMAIN]\e[0m"
    exit 1
fi

SHELL_PATH=$(dirname $(readlink -f $0))

echo -e "\e[1;33m## Sync install script...\e[0m"
${SHELL_PATH}/sync_file.sh $1 $2 ${SHELL_PATH}/image_install.sh /tmp
${SHELL_PATH}/sync_file.sh $1 $2 ${SHELL_PATH}/dea_install.sh /tmp

echo -e "\e[1;33m## remote install ...\e[0m"
${SHELL_PATH}/sync_cmd.sh $1 $2 "cd /tmp; nohup ./dea_install.sh $3 $4 $5 $6> /var/log/dea_install.log &"
