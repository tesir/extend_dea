#!/bin/bash

DOWNLOAD_ENDPOINT="http://10.168.111.185"

LOGFILE="/var/log/dea_install_status"
touch $LOGFILE
echo 'prepare' > $LOGFILE

if [ $# -lt 4 ] ; then
    echo -e "\e[1;33m!!!USEAGE: dea_install.sh [NATS_ADDR] [ETCD_ADDR] [PASSWORD] [DOMAIN]\e[0m"
    echo 'failed' > $LOGFILE
    exit 1
fi

NATS_ADDR=$1
ETCD_ADDR=$2
PASSWORD=$3
DOMAIN=$4


if [ ! -f image_install.sh ] ; then
    echo -e "\e[1;33m!!! image_install.sh is not exist \e[0m"
    echo 'failed' > $LOGFILE
    exit 1
fi

echo 'install image' > $LOGFILE
. ./image_install.sh

# 下载vcap并解压
cd /tmp 

echo 'download dea' > $LOGFILE
wget -q $DOWNLOAD_ENDPOINT/blobstore/207/dea_vcap.tar.bz2

echo 'tar dea' > $LOGFILE
tar xjf dea_vcap.tar.bz2 -C /

echo 'install monit' > $LOGFILE
echo -e "\e[1;33m## config monit ...\e[0m"
wget -q $DOWNLOAD_ENDPOINT/blobstore/monit.tar.bz2
tar xjf monit.tar.bz2
cp -f ./init.d/monit /etc/init.d
cp -f ./default/monit /etc/default
update-rc.d monit defaults
echo "/var/vcap/bosh/bin/monit start all" >> /etc/profile

# 更新配置
if [ "`echo $NATS_ADDR | grep -c ","`" != 0 ];then
    NATS_ADDR=`echo $NATS_ADDR | sed -n 's/,/ /p'`
fi

if [ "`echo $ETCD_ADDR | grep -c ","`" != 0 ];then
    ETCD_ADDR=`echo $ETCD_ADDR | sed -n 's/,/ /p'`
fi

NAT_SET="["

for NAT in $NATS_ADDR
do
  sed -i "/nats_servers/a\  - nats://nats:${PASSWORD}@${NAT}:4222" /var/vcap/jobs/dea_next/config/dea.yml
  NAT_SET=${NAT_SET}\"${NAT}\"","
done

NAT_SET=${NAT_SET%?}
NAT_SET=${NAT_SET}"]"

ETC_SET="["
for ETC in $ETCD_ADDR
do

  ETC_SET=${ETC_SET}\"${ETC}\"","
done

ETC_SET=${ETC_SET%?}
ETC_SET=${ETC_SET}"]"

sed -i "s/\"NatsHosts\".*/\"NatsHosts\": ${NAT_SET},/g" /var/vcap/jobs/dea_logging_agent/config/dea_logging_agent.json
sed -i "s/\"NatsHosts\".*/\"NatsHosts\": ${NAT_SET},/g" /var/vcap/jobs/metron_agent/config/metron_agent.json

sed -i "s#\"EtcdUrls\".*#\"EtcdUrls\": ${ETC_SET},#g" /var/vcap/jobs/dea_logging_agent/config/dea_logging_agent.json
sed -i "s#\"EtcdUrls\".*#\"EtcdUrls\": ${ETC_SET},#g" /var/vcap/jobs/metron_agent/config/metron_agent.json

# 更改域名信息
sed -i "s/domain:.*/domain: $DOMAIN/g" /var/vcap/jobs/dea_next/config/dea.yml

# 更新密码配置
sed -i "s/DreamDT228/${PASSWORD}/g" `grep -rl "DreamDT228" /var/vcap/jobs/*`

# 更改调试等级
sed -i "s/level:.*/level: warn/g" `grep -rl "level:" /var/vcap/jobs/*/config`

echo 'succeed' > $LOGFILE


#重启一下
echo -e "\e[1;33m## Now reboot ...\e[0m"
reboot
