# extend_dea
扩展dea节点脚本

说明：
extend_dea.sh 增加参数

extend_dea.sh [REMOTE_IP] [PASSWD] [NATS_ADDR] [ETCD_ADDR] [SYS_PASSWORD] [DOMAIN]

REMOTE_IP 目标ECS地址
PASSWD 目标ECSroot密码
NATS_ADDR PAAS平台消息总线地址， 格式 192.168.0.0,192.168.0.1,192.168.0.3  多个IP地址中间用,分割，不能有空格
ETCD_ADDR 同NATS_ADDR 但是需要带上端口号， 比如： 192.168.0.0：4001 目前端口默认都填4001
SYS_PASSWORD PAAS平台系统密码
DOMAIN PAAS平台域名
