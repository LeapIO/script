#!/bin/bash
#
#卸载所有的磁盘挂载（除了sda）
listDevice=($(df -lh | grep '/dev/sd[b-z]' | awk '{print $1}'))
listMountAddr=($(df -lh | grep '/dev/sd[b-z]' | awk '{print $6}'))
for var in ${listMountAddr[@]}
do
    umount $var
done

listTables=($(lsblk | grep sd[b-z] | awk '{print $1}    ' | sed 's/[^a-zA-Z]*//g'))
declare -A dictDiskTableNum #磁盘分区的数目
#统计磁盘分区的数目 主要用于初始化用于删除分区
for((i=0;i<${#listTables[@]};i++))
do
    if [ ! -v dictDiskTableNum[${listTables[${i}]}] ];then
        dictDiskTableNum[${listTables[${i}]}]=0
    else
        ((dictDiskTableNum[${listTables[${i}]}]++))
    fi
done
#删除分区
for key in $(echo ${!dictDiskTableNum[*]})
do
    declare -i n=${dictDiskTableNum[$key]}
    if [ $n == 0 ]; then
        continue
    fi

    deviceID="/dev/"$key
    str1="d\n"
    str2="d\n\n"
    commondStr=""
    for((i=0;i<n;i++))
    do
        if [ $n ==  1 ];then
            commondStr=${commondStr}${str1}
        else
            commondStr=${commondStr}${str2}
        fi
    done
    commondStr="${commondStr}wq"
    echo -e ${commondStr} | fdisk $deviceID
done

#分区 初始化文件系统 挂载
echo '输入分区数量:'
read pNum
echo '输入文件系统:'
read fs
echo '输入分区大小:'
read size
disk_name=(${!dictDiskTableNum[*]})
echo ${disk_name[*]}
for((i=0;i<${#disk_name[*]};i++))
do
    echo dev/${disk_name[i]}
    for((j=1;j<=pNum;j++))
    do
        echo "n
        p


        +${size}g
        wq" | fdisk /dev/${disk_name[i]}
        echo "y

        " | mkfs.${fs} /dev/${disk_name[i]}$j
        if [ ! -d "/mnt/${disk_name[i]}$j" ]; then
            mkdir /mnt/${disk_name[i]}$j
            mount /dev/${disk_name[i]}$j /mnt/${disk_name[i]}$j
        else
            mount /dev/${disk_name[i]}$j /mnt/${disk_name[i]}$j
        fi

    done
done

echo "############# dd 指令#################"
midfile="/mnt/sdb1/testw.dbf"
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
