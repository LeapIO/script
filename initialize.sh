#!/bin/bash

vdbenchPath="/root/vdbench/vdbench"
#查找pcie接口及其挂载盘符
#获取pci地址列表
list1=($(lshw -short -C disk | awk '{print $1}' | sed -n '3,$p' |sed ":label;N;s/\n/ /;b label"))

size=${#list1[*]}
list3[0]=A
for((i=0;i<$size;i++))
do
        a=($(echo ${list1[$i]} | sed 's/\// /g'));
        pci_list[$i]=${a[1]}
#        echo ${a[*]}
done

#获取disk列表 取出模式sdb sdc sdd...
disklist=($(lshw -short -C disk | awk '{print $2}' | sed -n '3,$p' |sed ":label;N;s/\n/ /;b label" | sed 's/\/dev\///g'))


echo '第一行为pcie接口，第二行为pcie接口下的磁盘'
printf "%-8s" ${pci_list[*]}
echo ' '
printf "%-8s" ${disklist[*]}
echo ' '

# 接口及其连接设备数量的映射
declare -A mapping
for((i=0;i<${#pci_list[@]};i++))
do
    if [ ! -v mapping[${pci_list[${i}]}] ];then
        mapping[${pci_list[${i}]}]=1

    else
        ((mapping[${pci_list[${i}]}]++))

    fi
done
echo "pcie接口: ${!mapping[*]}"
echo "pcie相应的设备数量: ${mapping[*]}"

echo "输入测试接口"
read pcie_add
pcie_dev_num=${mapping[$pcie_add]}
for((i=0;i<${#pci_list[@]};i++))
do
        if [ $pcie_add -eq ${pci_list[$i]} ]
        then
                pcie=${disklist[*]:$i:$pcie_dev_num}
                break
        fi
done
echo "接口下的磁盘："
echo ${pcie[*]}

#模式转换 sdb|sdc|sdd|sde
dev_str=$(echo ${pcie[*]}|sed 's/ /|/g');
#echo $dev_str


#
#卸载所有的磁盘挂载
listMountAddr=($(df -lh | grep -E $dev_str | awk '{print $6}'))
for var in ${listMountAddr[@]}
do
    umount $var
done

listTables=($(lsblk | grep -E $dev_str | awk '{print $1}    ' | sed 's/[^a-zA-Z]*//g'))
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
#调用fio.sh
#echo "盘符信息:"$dev_str
./fio.sh $dev_str

#调用vdbench
./gen_vdbench_config.sh $dev_str
${vdbenchPath} -f ./vdbench.conf -o ./vdbench/output
