# script
test scripts or tools, etc
1. 主脚本是 initalize.sh
   主要功能是查找PCI设备，并找到PCI对应设备上的盘符  
   根据找到的盘符，做出如下的操作：  
   1）umount 对应的挂载  
   2）对磁盘进行分区、制作文件系统（格式化）、挂载  
   3) 调用fio.sh脚本，进行磁盘测试  
   4) 调用vdbench命令，进行磁盘测试  
2. fio.sh
   包含了所有的fio指令，存储在fun_list()这个数组里面。  
   #格式 numjobs_ioengine_iodepth_bs_size_runtime_rw_rwmixread  
   示例 fun_list=('10_libaio_8_4K_1G_60_read'  
        #'1_libaio_1_1K_5G_600_randread'  
        )
   添加删除fio指令集，只需要修改此数组。  
3. 调用vdbench
   需要修改 vdbenchPath="/root/vdbench/vdbench" 这个参数值（vdbench的安装目录下的vdbench脚本位置）  
   vdbench指令参数配置主要由 gen_vdbench_config.sh这个脚本生成。  
   若需要修改vdbench的运行参数，直间修改gen_vdbench_config.sh此脚本内容。
    
