#!/bin/bash -ex

if [ $# != 3 ] ; then 
  echo -e "\e[1;33m!!!USEAGE: replace_identify.sh [IDENTIFY] [IP_ADDR] [ROOT_PASSWORD]\e[0m"
  exit 1; 
fi

IDENTIFY=$1
IP_ADDR=$2
ROOT_PASSWORD=$3

SHELL_PATH=$(dirname $(readlink -f $0))

#替换identify
${SHELL_PATH}/sync_cmd.sh $IP_ADDR $ROOT_PASSWORD "sed -i 's/identify.*/identify: $IDENTIFY/g' /var/vcap/jobs/dea_next/config/dea.yml"
#重启服务
${SHELL_PATH}/sync_cmd.sh $IP_ADDR $ROOT_PASSWORD "/var/vcap/bosh/bin/monit restart all"
