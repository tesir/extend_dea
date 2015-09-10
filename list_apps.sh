#!/bin/bash

if [ $# -lt 2 ] ; then
    echo -e "\e[1;33m!!!USEAGE: check_status.sh [IP_ADDR] [PASSWORD]\e[0m"
    exit 1
fi

./sync_cmd.sh $1 $2 "grep -r 'application_name' /var/vcap/data/dea_next/db/instances.json"
