#!/bin/bash
#获取盘符信息
dev_str=$1
dev_list=($(echo $dev_str | sed 's/|/ /g'))
#numjobs 线程数
#ioengine 指定IO引擎  sync、libaio、psync、vsync、mmap等等
#iodepth 队列深度
#bs     单次IO块大小
#size   每个线程读的数据量
#runtime 测试时间
#rw     读写方式
#rwmixread 混合读写读占的比例 eg:70 == 70%read 30write
#要执行的指令参数列表（一般只用修改此数组）
#格式 numjobs_ioengine_iodepth_bs_size_runtime_rw_rwmixread
fun_list=('10_libaio_8_4K_1G_60_read'
	#'1_libaio_1_1K_5G_600_randread'
	#'1_libaio_1_1K_5G_600_write'
	#'1_libaio_1_1K_5G_600_randwirte'
	#'1_libaio_1_1K_5G_600_rw_70'
	#'1_libaio_1_1K_5G_600_randrw_70'
)
numjobs=''
ioengine=''
iodepth=''
bs=''
size=''
runtime=''
rw=''
rwmixread=''
#解析要执行的命令参数列表
function analysis_para(){
	str=$2
	para_list=($(echo $str|sed 's/_/ /g'))
	numjobs=${para_list[0]}
	ioengine=${para_list[1]}
	iodepth=${para_list[2]}
	bs=${para_list[3]}
	size=${para_list[4]}
	runtime=${para_list[5]}
	rw=${para_list[6]}
	isrw=0
	if [ $rw = 'rw' -o $rw = 'randrw' ];then
		isrw=1
		rwmixread=${para_list[7]}
	fi
	#判断是否混合读写
	if [ $isrw -eq 0 ];then
		fio -filename=$1 -direct=1 -group_reporting -name=${1}"_"${2} -thread -numjobs=$numjobs -ioengine=$ioengine -iodepth=$iodepth -bs=$bs -size=$size -runtime=$runtime -rw=$rw
	else
		fio -filename=$2 -direct=1 -group_reporting -name=${1}"_"${2} -thread -numjobs=$numjobs -ioengine=$ioengine -iodepth=$iodepth -bs=$bs -size=$size -runtime=$runtime -rw=$rw -rwmixread=$rwmixread
	fi
}
###外层循环是要执行的指令 内层循环是要执行的盘符
for fun_name in ${fun_list[@]}
do
	for device_name in ${dev_list[@]}
	do
		analysis_para $device_name $fun_name
	done
done
