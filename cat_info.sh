#!/bin/bash

CPU=`cat /proc/cpuinfo |grep processor |wc -l`
MEM=`cat /proc/meminfo |grep 'MemTotal' |awk -F : '{print $2}' |sed 's/^[ t]*//g'`
DISK=`fdisk -l |grep 'Disk' |awk -F , '{print $1}' | sed 's/Disk identifier.*//g' | sed '/^$/d' | sed 's#/dev/##g'`

echo "CPU Number: $CPU"
echo "Mem total: $MEM"
echo "$DISK"
