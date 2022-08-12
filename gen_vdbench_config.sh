#!/bin/bash
#获取盘符信息
dev_str=$1
dev_list=($(echo $dev_str | sed 's/|/ /g'))
cat /dev/null > ./vdbench.conf
#creat SD
#sd= 标识存储的名称。
#host= 存储所在的主机的 ID。
#lun= 原始磁盘、磁带或文件系统的名称。vdbench 也可为您创建一个磁盘。
#threads= 对 SD 的最大并发 I/O 请求数量。默认为 8。
#hitarea= 调整读取命中百分比的大小。默认为 1m。
#openflags= 用于打开一个 lun 或一个文件的 flag_list。
sd_list=()
sd=''
host=''
lun=''
threads=''
hitarea=''
openflags='o_direct'
for((i=0;i<${#dev_list[@]};i++))
do
	str="sd=sd$(expr ${i} + 1),lun=/dev/${dev_list[i]},openflag=${openflags}"
	#sd_list[${#sd_list[@]}]=str
	echo $str | tee -a ./vdbench.conf
done

#creat WD
#wd= 标识工作负载的名称。
#sd= 要使用的存储定义的 ID。
#host= 要运行此工作负载的主机的 ID。默认设置为 localhost。
#rdpct= 读取请求占请求总数的百分比。
#rhpct= 读取命中百分比。默认设置为 0。
#whpct= 写入命中百分比。默认设置为 0。
#xfersize= 要传输的数据大小。默认设置为 4k。
#seekpct= 随机寻道的百分比。可为随机值。
#openflags= 用于打开一个 lun 或一个文件的 flag_list。
#iorate= 此工作负载的固定 I/O 速率。

echo "wd=wd1,sd=sd*,rdpct=0,xfersize=1k" | tee -a ./vdbench.conf
echo "wd=wd2,sd=sd*,rdpct=100,xfersize=100k" | tee -a ./vdbench.conf
#echo "wd=wd2,sd=sd*,rdpct=50,xfersize=16k" | tee -a ./vdbench.conf
#echo "wd=wd3,sd=sd*,rdpct=10,xfersize=100k" | tee -a ./vdbench.conf
#echo "wd=wd4,sd=sd*,rdpct=90,xfersize=1k" | tee -a ./vdbench.conf

#creat RD
#rd= 标识运行的名称。
#wd= 用于此运行的工作负载的 ID。
#iorate= (#,#,...) 一个或多个 I/O 速率。
#curve：性能曲线（待定义）。
#max：不受控制的工作负载。
#elapsed= time：以秒为单位的运行持续时间。默认设置为 30。
#interval：报告间隔序号
#warmup= time：加热期，最终会被忽略。
#distribution= I/O 请求的分布：指数、统一或确定性。
#pause= 在下一次运行之前休眠的时间，以秒为单位。
#openflags= 用于打开一个 lun 或一个文件的 flag_list。
echo "rd=rd1,wd=wd1,iorate=max,warmup=10,elapsed=40,interval=10" | tee -a ./vdbench.conf
echo "rd=rd2,wd=wd2,iorate=max,warmup=10,elapsed=40,interval=10" | tee -a ./vdbench.conf
