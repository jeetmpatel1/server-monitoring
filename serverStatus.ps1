###################################################### Email Config ######################################################
$EmailTo = "email@email.com"  

$SMTPServer = "smtp.gmail.com" 

$EmailFrom = "email@email.com" 

$EmailTimeOut = 60 # 5 Minutes

$SleepTimeOut =30 # 2 Minutes

###################################################### Config Ended ######################################################

$OutageHosts = $Null 
Do{ 

        $AvailableServersList = $Null 
        $UnavailableServersList = $Null 

        $CurrentTimeStamp= (Get-Date -UFormat "%Y-%m-%d %r %Z" | ForEach-Object { $_ -replace ":", "-" } | ForEach-Object { $_ -replace " ", "_" })
        $LogFileOutputPath='.\'+$CurrentTimeStamp+".log"
        #New-Item -Path $LogFileOutputPath -ItemType File -Force 
        $StartingText = "Script Started at " + $CurrentTimeStamp
        
        write-host $StartingText
        write-output $StartingText | Out-File -FilePath $LogFileOutputPath -Append

        get-content .\serverStatusList.config | Where-Object {!($_ -match "#")} | ForEach-Object { 
                $status = Test-Connection -ComputerName $_ -Count 1 -ea silentlycontinue -Quiet
                if($status){
                        if($OutageHosts -ne $Null -and $OutageHosts.ContainsKey($_)){
                                #Potential candidate where mail should be sent stating that the server is now available
                                $secpasswd = ConvertTo-SecureString "lggcvgwwofgcsizr" -AsPlainText -Force
                                $cred = New-Object System.Management.Automation.PSCredential ("email@email.com", $secpasswd)
                                Send-MailMessage  -SmtpServer $SMTPServer -From 'email@email.com' -To 'email@email.com' -Subject "Server is available $_" -Body "$_ is available now. First time stopped at  $($OutageHosts[$_]). Current time is  $(Get-Date)"  -Credential $cred -UseSsl
                                $OutageHosts.remove($_)     
                                [Array]$AvailableServersList += $_    
                        }else{
                                write-output "" | Out-File -FilePath $LogFileOutputPath -Append
                                write-output "Available host ---> "$_  | Out-File -FilePath $LogFileOutputPath -Append
                                [Array]$AvailableServersList += $_ 
                        }
                }
                else{ 
                        write-output "" | Out-File -FilePath $LogFileOutputPath -Append
                        write-output "Unavailable server ----------------------------> "$_   | Out-File -FilePath $LogFileOutputPath -Append
                        $status = Test-Connection -ComputerName $_ -Count 3 -ea silentlycontinue -Quiet  
                        if($status){
                                write-output "host is available now ------------> "$_ | Out-File -FilePath $LogFileOutputPath -Append
                                [Array]$AvailableServersList += $_
                        }
                        else{
                                write-output "Unavailable host After 5 retries ------------> "$_   | Out-File -FilePath $LogFileOutputPath -Append
                                [Array]$UnavailableServersList += $_ 
                                if ($OutageHosts -ne $Null){ 
                                                if (!$OutageHosts.ContainsKey($_)){ 
                                                        write-output "$_ Is Down.Adding to tracking list."  | Out-File -FilePath $LogFileOutputPath -Append
                                                        $OutageHosts.Add($_,(get-date)) 
                                                } 
                                                else{ 
                                                        # If the host is in the list do nothing for 1 hour and then remove from the list. 
                                                        write-output "$_ Is in the OutageHosts list"  | Out-File -FilePath $LogFileOutputPath -Append
                                                        $time = (((Get-Date) - $OutageHosts.Item($_)).TotalMinutes)*60
                                                        Write-output $time | Out-File -FilePath $LogFileOutputPath -Append
                                                        if ($time -gt $EmailTimeOut){
                                                                $secpasswd = ConvertTo-SecureString "lggcvgwwofgcsizr" -AsPlainText -Force
                                                                $cred = New-Object System.Management.Automation.PSCredential ("email@email.com", $secpasswd)
                                                                Send-MailMessage  -SmtpServer $SMTPServer -From 'email@email.com' -To 'email@email.com' -Subject "Server is unavailable $_" -Body "$_ is unavailable for more than 5 minutes. First time stopped at  $($OutageHosts[$_]). Current time is  $(Get-Date)"  -Credential $cred -UseSsl
                                
                                                        } 
                                                } 
                                } 
                                else{ 
                                        # First time down create the list and send email 
                                        write-output "Adding $_ to OutageHosts."  | Out-File -FilePath $LogFileOutputPath -Append
                                        $OutageHosts = @{$_=(get-date)} 
                                } 
                        } 
                } 
        } 

        ##########################     Table Functionality     ##########################
        
        $tabName = "StatisticsTab"

        $table = New-Object system.Data.DataTable “$tabName”
        $col1 = New-Object system.Data.DataColumn Description,([string])
        $col2 = New-Object system.Data.DataColumn Count,([string])
        $table.columns.add($col1)
        $table.columns.add($col2)

        $row = $table.NewRow()
        $row.Description = "Available count"
        $row.Count = $AvailableServersList.count

        $row1 = $table.NewRow()
        $row1.Description = "Unavailable count"
        $row1.Count = $UnavailableServersList.count

        #Add the row to the table
        $table.Rows.Add($row)
        $table.Rows.Add($row1)

        foreach ($key in $OutageHosts.Keys){
                $rowa = $table.NewRow()
                $rowa.Description = ""+ $key
                $rowa.Count = ""+ $OutageHosts[$Key]
                $table.Rows.Add($rowa)
        }
        write-host $($table | format-table -AutoSize | Format-Wide | Out-String)

        ##########################     Mail Functionality     ##########################
       
        $html = "<table><tr><td><b>Scenario</b></td><td><b>Count</b></td></tr>"
        foreach ($row in $table.Rows)
        { 
                $html += "<tr><td>" + $row[0] + "</td><td>" + $row[1] + "</td></tr>"
        }
        $html += "</table>"

        #$table | format-table -AutoSize | Format-Wide | Out-String

        $Subject = "Server Outage Script - " +  $CurrentTimeStamp
        #$Body =$($table | format-table -AutoSize | Out-String) 
        $Body = $html

        
        $filenameAndPath = $PSScriptRoot+ "\" +  $CurrentTimeStamp + ".log"
        $SmtpMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
        $SmtpMessage.IsBodyHtml = $True;
        $attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
        $SmtpMessage.Attachments.Add($attachment)
        $SmtpClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
        $SmtpClient.EnableSsl = $true 
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential("email@email.com", "lggcvgwwofgcsizr");   
        
        $SmtpClient.Send($SmtpMessage)
        $SmtpMessage.Attachments.Dispose()

        write-host "Script Executed Successfully."
        write-output "Script Executed Successfully."  | Out-File -FilePath $LogFileOutputPath -Append
    
        write-output "Sleeping $SleepTimeOut seconds"  | Out-File -FilePath $LogFileOutputPath -Append
        sleep $SleepTimeOut 

        #if ($OutageHosts.Count -gt $MaxOutageCount){ } 

} while ($Exit -ne $True) 