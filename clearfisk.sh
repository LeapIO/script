#!/bin/bash
listTables=($(lsblk | grep sd[b-z] | awk '{print $1}    ' | sed 's/[^a-zA-Z]*//g'))
declare -A dictDiskTableNum #磁盘分区的数目
#统计磁盘分区的数目 主要用于初始化用于删除分区
for((i=0;i<${#listTables[@]};i++))
do
    if [ ! -n dictDiskTableNum[${listTables[${i}]} ];then
        dictDiskTableNum[${listTables[${i}]}]=0
    else
        ((dictDiskTableNum[${listTables[${i}]}]++))
	fi
done
#删除分区
for key in $(echo ${!dictDiskTableNum[*]})
do
	declare -i n=${dictDiskTableNum[$key]}
	if [ n==0 ]; then
		continue
	fi

	deviceID="/dev/"$key
	str1="d\n"
	str2="d\n\n"
	commondStr=""
	for((i=0;i<n;i++))
	do
		if [ n==1 ];then
			commondStr=${commondStr}${str1}
		else
			commondStr=${commondStr}${str2}
		fi
	done
	commondStr="${commondStr}wq"
	echo -e ${commondStr} | fdisk $deviceID
done

#创建新分区和文件系统 有点问题 下次更新
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
    for((j=0;j<pNum;j++))
    do
        echo "n
        p


        +${size}g
        wq" | fdisk /dev/${disk_name[i]}
        mkfs.${fs} /dev/${disk_name[i]}$j
    done
done
