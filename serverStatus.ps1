###################################################### Email Config ######################################################
$EmailTo = "email@email.com"  

$SMTPServer = "smtp.gmail.com" 

$EmailFrom = "email@email.com" 

$EmailTimeOut = 60 # 5 Minutes

$SleepTimeOut =20 # 2 Minutes

###################################################### Config Ended ######################################################

$OutageHosts = $Null 
Do{ 

    $AvailableServersList = $Null 
    $UnavailableServersList = $Null 
   
    $CurrentTimeStamp= (Get-Date -UFormat "%Y-%m-%d %r %Z" | ForEach-Object { $_ -replace ":", "-" } | ForEach-Object { $_ -replace " ", "_" })
    $LogFileOutputPath='.\'+$CurrentTimeStamp+".log"
    #New-Item -Path $LogFileOutputPath -ItemType File -Force 
    $StartingText = "Script Started at " + $CurrentTimeStamp
    
    write-host "$StartingText"
    write-output $StartingText | Out-File -FilePath $LogFileOutputPath -Append

    get-content .\serverStatusList.config | Where-Object {!($_ -match "#")} | ForEach-Object { 
        $status = Test-Connection -ComputerName $_ -Count 1 -ea silentlycontinue -Quiet
        if($status){
                 write-output "" | Out-File -FilePath $LogFileOutputPath -Append
                 write-output "Available host ---> "$_  | Out-File -FilePath $LogFileOutputPath -Append
                 [Array]$AvailableServersList += $_ 
        }
        else{ 
                write-output "" | Out-File -FilePath $LogFileOutputPath -Append
                write-host "Unavailable server ----------------------------> "$_  
                write-output "Unavailable server ----------------------------> "$_   | Out-File -FilePath $LogFileOutputPath -Append
                $status = Test-Connection -ComputerName $_ -Count 5 -ea silentlycontinue -Quiet  
                if($status){
                        write-output "host is available now ------------> "$_ | Out-File -FilePath $LogFileOutputPath -Append
                        [Array]$AvailableServersList += $_
                }
                else{
                        write-host "Unavailable host After 5 retries ------------> "$_
                        write-output "Unavailable host After 5 retries ------------> "$_   | Out-File -FilePath $LogFileOutputPath -Append
                        [Array]$UnavailableServersList += $_ 
                        if ($OutageHosts -ne $Null){ 
                                            if (!$OutageHosts.ContainsKey($_)){ 
                                                write-host "adding to outage list " + $_
                                                write-output "$_ Is Down.Adding to tracking list."  | Out-File -FilePath $LogFileOutputPath -Append
                                                $OutageHosts.Add($_,(get-date)) 
                                            } 
                                            else{ 
                                                    # If the host is in the list do nothing for 1 hour and then remove from the list. 
                                                    write-host ($OutageHosts | Out-String) 
                                                    write-host "$_ Is in the OutageHosts list" 
                                                    write-output "$_ Is in the OutageHosts list"  | Out-File -FilePath $LogFileOutputPath -Append
                                                    $time = (((Get-Date) - $OutageHosts.Item($_)).TotalMinutes)*60
                                                    write-host " Time elapsed since last entry " $time +"  "   $_ "  " ;
                                                    if ($time -gt $EmailTimeOut){
                                                        Write-Host "A Mail will be sent "
                                                    } 
                                            } 
                        } 
                        else{ 
                                # First time down create the list and send email 
                                write-host "adding to outage list " + $_
                                write-output "Adding $_ to OutageHosts."  | Out-File -FilePath $LogFileOutputPath -Append
                                $OutageHosts = @{$_=(get-date)} 
                        } 
                } 
        } 
    } 

    $Stats = "";
    $Stats += "`r`n" 
    $Stats += "======================================"
    $Stats += "`r`n" 
    $Stats += "Available count:" + $AvailableServersList.count
    $Stats += "`r`n"
    $Stats += "Not available count:" + $UnavailableServersList.count
    $Stats += "`r`n"
    $Stats += "`r`n"
    $Stats += "Un available hosts:"
    $Stats += "`r`n"
    $Stats += ($OutageHosts | Out-String) 
    $Stats += "`r`n" 
    $Stats += "======================================"
    
    Write-Host $Stats
    
    #write-output ""  | Out-File -FilePath $LogFileOutputPath -Append
    #write-output "======================================" | Out-File -FilePath $LogFileOutputPath -Append
    #write-output "Available count:"$available.count  | Out-File -FilePath $LogFileOutputPath -Append
    #write-output "Not available count:"$UnavailableServersList.count  | Out-File -FilePath $LogFileOutputPath -Append
    #write-output "" | Out-File -FilePath $LogFileOutputPath -Append
    #write-output "Un available hosts:"  | Out-File -FilePath $LogFileOutputPath -Append
    #write-output ($OutageHosts | Out-String) | Out-File -FilePath $LogFileOutputPath -Append
    #write-output "======================================" | Out-File -FilePath $LogFileOutputPath -Append
    #write-output ""  | Out-File -FilePath $LogFileOutputPath -Append
    
    write-output $Stats  | Out-File -FilePath $LogFileOutputPath -Append

    #write-output "Sleeping $SleepTimeOut seconds"  | Out-File -FilePath $LogFileOutputPath -Append
   

    $Subject = "Server Outage Script - " +  $CurrentTimeStamp
    $Body = $Stats 
    $filenameAndPath = "./" +   $CurrentTimeStamp + ".log"
    #$test = Get-Item -Path 
    write-host $filenameAndPath;
    $SmtpMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    #$attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
    #$SMTPMessage.Attachments.Add($attachment)
    $SmtpClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SmtpClient.EnableSsl = $true 
    $SmtpClient.Credentials = New-Object System.Net.NetworkCredential("email@email.com", "lggcvgwwofgcsizr");   
    
    $SmtpClient.Send($SmtpMessage)


    write-host "Script Executed Successfully."
    write-output "Script Executed Successfully."  | Out-File -FilePath $LogFileOutputPath -Append
    
    sleep $SleepTimeOut 

    #if ($OutageHosts.Count -gt $MaxOutageCount){ } 

} while ($Exit -ne $True) 