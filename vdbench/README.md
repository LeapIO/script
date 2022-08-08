        在vdbench下面运行 ./vdbench -f 脚本位置
        运行结束后会生成一个output文件夹，里面存放测试结果（会给出文件夹地址）
        具体测试前可以先运行一下test看看是否是期望输出  test对sdb和c读写各三十秒 ...
        （1）HD：主机定义
         •    如果您希望展示当前主机，则设置 hd= localhost。如果希望指定一个远程主机，hd= label。
         •    system= IP 地址或网络名称。
         注意：vdbench=dir ，这里的目录是指所有主机上的目录，这就表示，所有主机上的vdbench目录都要一样，且对应的配置要放在vdbench下面；

        （2）SD：存储定义
         •    sd= 标识存储的名称。
         •    host= 存储所在的主机的 ID。
         •    lun= 原始磁盘、磁带或文件系统的名称。vdbench 也可为您创建一个磁盘。
         •    threads= 对 SD 的最大并发 I/O 请求数量。默认为 8。
         •    hitarea= 调整读取命中百分比的大小。默认为 1m。
         •    openflags= 用于打开一个 lun 或一个文件的 flag_list，为了贴近真实场景，一般在这里选择o_direct，绕过缓存机制，直接写盘

         （3）WD：工作负载定义
         •    wd= 标识工作负载的名称。
         •    sd= 要使用的存储定义的 ID。
         •    host= 要运行此工作负载的主机的 ID。默认设置为 localhost。
         •    rdpct= 读取请求占请求总数的百分比。
         •    rhpct= 读取命中百分比。默认设置为 0。
         •    whpct= 写入命中百分比。默认设置为 0。
         •    xfersize= 要传输的数据大小。默认设置为 4k。
         •    seekpct= 随机寻道的百分比。可为随机值。
         •    openflags= 用于打开一个 lun 或一个文件的 flag_list。
         •    iorate= 此工作负载的固定 I/O 速率。

         （4）RD：运行定义
         •    rd= 标识运行的名称。
         •    wd= 用于此运行的工作负载的 ID。
         •    iorate= (#,#,…) 一个或多个 I/O 速率。（这里可以控制运行的iops，如果不控制就设置成max）
         •    elapsed= time：以秒为单位的运行持续时间。默认设置为30。(设置长时间的运行，可能会使得数据更加稳定)
         •    warmup= time：加热期，最终会被忽略。
         •    distribution= I/O 请求的分布：指数、统一或确定性。
         •    pause= 在下一次运行之前休眠的时间，以秒为单位。
         •    openflags= 用于打开一个 lun 或一个文件的 flag_list。

         （5）output文件夹：
             （1）errorlog.html——当为测试启用了数据验证（-jn）时，它可包含一些数据块中的错误的相关信息：

             无效的密钥读取

             无效的 lba 读取（一个扇区的逻辑字节地址）

             无效的 SD 或 FSD 名称读取

             数据损坏，即使在使用错误的 lba 或密钥时

             数据损坏

             坏扇区

            （2）flatfile.html——包含 vdbench 生成的一种逐列的 ASCII 格式的信息。

            （3）histogram.html——一种包含报告柱状图的响应时间、文本格式的文件。

            （4）logfile.html——包含 Java 代码写入控制台窗口的每行信息的副本。logfile.html 主要用于调试用途

            （5）parmfile.html——显示已包含用于测试的每项内容的最终结果

            （6）resourceN-M.html、resourceN.html、resourceN.var_adm_msgs.html

                     摘要报告、stdout/stderr 报告、主机 N 的摘要报告

            最后 “nn” 行文件 /var/adm/messages 和 /var/adm/messages。每个 M 个 JVM/Slave 的目标主机 N 和主机 N 上为 0。

            （7）sdN.histogram.html、sdN.html——每个 N 存储定义的柱状图和存储定义 “N” 报告。

            （8）summary.html——主要报告文件，显示为在每个报告间隔的每次运行生成的总工作负载，以及除第一个间隔外的所有间隔的加权平均值。

             interval：报告间隔序号

             I/O rate：每秒观察到的平均 I/O 速率

             MB sec：传输的数据的平均 MB 数

             bytes I/O：平均数据传输大小

             read pct：平均读取百分比

             resp time：以读/写请求持续时间度量的平均响应时间。所有 vdbench 时间都以毫秒为单位。

             resp max：在此间隔中观察到的最大响应时间。最后一行包含最大值总数。

             resp stddev：响应时间的标准偏差

             cpu% sys+usr：处理器繁忙 = 100（系统 + 用户时间）（Solaris、Windows、Linux）

             cpu% sys：处理器利用率：系统时间

            （9）swat_mon.txt，swat_mon_total.txt

            vdbench 与 Sun StorageTekTM Workload Analysis Tool (Swat) Trace Facility (STF) 相结合，支持重放使用 Swat 创建的一个轨迹的 I/O 工作负载。
             Swat 使用 Create Replay File 选项创建和处理的轨迹文件会创建文件 flatfile.bin（flatfile.bin.gz 用于 vdbench403 和更高版本），其中包含 Swat 所识别的每个 I/O 操作的一条记录。
