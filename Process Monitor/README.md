# Process Monitor--进程监控脚本 
> 监控需要的信息大致如下： 
1. 程序所在机器的IP和名称 
2. 程序的状态，是在执行还是已经停止 
3. 监控信息写入到日志的时间 

## 文件介绍 
**all.sh**  
```bash 
#!/bin/bash 

sleep 25 & 改成被监控程序的启动命令语句 
sh /root/monitor/monitor.sh $! & monitor.sh脚本的绝对路径 
``` 

**monitor.sh**  
该文件是主要的监控脚本，可配置的参数项有一下几个：  
```bash
#======CONFIG======#

#Name of the network adapter.
NIC="eth0"

#Set detection cycle,units are seconds.
INTERVAL=10

#Log files in the directory.
LOGDIR="/root/monitor/logs"

#Set the number of log file archiving.
#The logs will be archived once a day.
ROTATE=30
```

**日志格式**  
`日期 时间 - 主机名 - 网卡IP - 进程状态`  
例如：  
```bash
2017/08/09 11:44:31 - db01 - 172.30.10.99 - Program run!
2017/08/09 11:44:41 - db01 - 172.30.10.99 - Program out!
2017/08/09 11:50:33 - db01 - 172.30.10.99 - Program run!
2017/08/09 11:50:43 - db01 - 172.30.10.99 - Program out!
```