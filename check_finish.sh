#!/bin/bash

if [ $# -lt 2 ] ; then
    echo -e "\e[1;33m!!!USEAGE: check_status.sh [IP_ADDR] [PASSWORD]\e[0m"
    exit 1
fi

CMD="cat /var/log/dea_install_status"

STATUS=`expect -D 0 -c"
set timeout 1
spawn ssh root@$1 \"$CMD\"
expect {
    \"*assword\" {send \"$2\r\";}
    \"yes/no\" {send \"yes\r\"; exp_continue;}
    timeout      { exit 1;}  
    }
expect eof
"`

#echo $STATUS

if [ "`echo $STATUS | grep -c "succeed"`" != 0 ];then
    echo -e "succeed"
    exit 0
fi

if [ "`echo $STATUS | grep -c "failed"`" != 0 ];then
    echo -e "failed"
    exit 0
fi

if [ "`echo $STATUS | grep -c "No such file"`" != 0 ];then
    echo -e "noprocess"
    exit 0
fi

echo "installing"
