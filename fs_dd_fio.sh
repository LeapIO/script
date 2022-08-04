#!/bin/bash
device="/dev/sdb"
mountaddr="/mnt/disk2"
mkdir $mountaddr
echo "创建文件系统"
echo "n
p
1


wq" | fdisk $device && mkfs.ext4 $device"1"
mount /dev/sdb1 $mountaddr
echo "创建文件系统完成"

echo "############# dd 指令#################"
midfile="/mnt/disk2/testw.dbf"
number=1000000
echo "测试磁盘写能力"
time dd if=/dev/zero bs=4k count=$number of=$midfile
echo "测试磁盘读能力"
time dd if=/dev/sdb bs=4k count=$number of=/dev/null
echo "测试磁盘同时读写能力"
time dd if=/dev/sdb bs=4k count=$number of=$midfile

echo "############# fio 指令#################"
echo "fio指令  70%随机读，30%随机写，5G大小，4k块文件："
readrat=70
fio -filename=/dev/sdc \
 -direct=1 -ioengine=libaio \
 -bs=4k -size=5G -numjobs=10 \
 -iodepth=16 -runtime=60 \
 -thread -rw=randrw -rwmixread=$readrat \
 -group_reporting \
 -name="TDSQL_4KB_randread70-write_test"
