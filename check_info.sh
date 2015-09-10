#!/bin/bash

if [ $# -lt 2 ] ; then
    echo -e "\e[1;33m!!!USEAGE: check_info.sh [IP_ADDR] [PASSWORD]\e[0m"
    exit 1
fi

SHELL_PATH=$(dirname $(readlink -f $0))

${SHELL_PATH}/sync_file.sh $1 $2 ${SHELL_PATH}/cat_info.sh /tmp  > /dev/null

${SHELL_PATH}/sync_cmd.sh $1 $2 "cd /tmp; ./cat_info.sh; rm -rf cat_info.sh" | sed '1,2d' 

