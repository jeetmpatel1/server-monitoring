# server-monitoring

This repository contains powershell scripts that can be used to monitor the remote server. Script runs indefinetly and checks the remote server via ping. If it is unavailabel, it waits and try 3 times (default) before defining it as unavilable.   


### Project Structure and Information


```
project_dir
│  log_monitor.ps1
│  sendEmail.ps1
│  serverStatus.ps1
│  serverStatusList.config
└───logs
│   │   YYYY-MM-dd-hh-mm-ss.log
│   │   zip_YYYY-MM-dd-hh-mm-ss.log
└───zips
│   │   YYYY-MM-dd.zip
│   │   fYYYY_MM_dd_hh_mm_ss.zip
```


| File | Usage |
| ------ | ------ |
| log_monitor.ps1 | archive all the logs older than 5 days in /zips directory.  Removes all zips older than 30 days from /zip directory. |
| sendEmail.ps1  | mail format |
| serverStatus.ps1  | repeatedly checks remote servers and write its status in /logs folder |
| serverStatusList.config | contains list of servers to be monitored |
| *.log  | log file of serverStatus.ps1 |
| zip_*.log  | log file of log_monitor.ps1 |
| yyyy-mm-dd.zip | contains all the log files of *.log and zip_*.log |
| yyyy-mm-dd_hh_mm_ss.zip | If a day has more zip files, then all those zip files are named like this. |
   
      
         
         
### Configure Script

  - Define servers to be monitored in the [serverStatusList.config](https://github.com/jeetmpatel1/server-monitoring/blob/master/serverStatusList.config) file.
  - Define email parameters to be used in the top header of  [serverStatus.ps1](https://github.com/jeetmpatel1/server-monitoring/blob/master/serverStatus.ps1) file. 
  - ```sh
    ################### Email Config ###################################
    $EmailTo = "email@email.com"  
    $SMTPServer = "smtp.gmail.com" 
    $EmailFrom = "email@email.com" 
    $EmailTimeOut = 60 # 5 Minutes
    $SleepTimeOut =30 # 2 Minutes
    $NumberOfTimesToConnectToServerBeforeDeclaringOutage =3
    ################### Config Ended ###################################
    ```
- When you run the [serverStatus.ps1](https://github.com/jeetmpatel1/server-monitoring/blob/master/serverStatus.ps1) , If server is unavailable after 5 retries, it will send email to the user specified in point 3 above. If some server was unavailable and now, it is available then also it will send email to the user. 
- With every execution of [serverStatus.ps1](https://github.com/jeetmpatel1/server-monitoring/blob/master/serverStatus.ps1), a log file with current timestamp in logs directory will be created. 
-  [log_monitor.ps1](https://github.com/jeetmpatel1/server-monitoring/blob/master/log_monitor.ps1) will archive all the log files older than 5 days into /zip directory. It will also delete all the archives under /zips directory which are older than 30 days. This execution will generate a log file zip_currenttimestamp. 

