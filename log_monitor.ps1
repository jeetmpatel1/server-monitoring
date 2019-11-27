$LogFilesPath = "C:\Users\jmpatel\Desktop\server-monitoring\logs\"
$ZipFilesPath = "C:\Users\jmpatel\Desktop\server-monitoring\zips\"
$LogDaysCriteria = $((Get-Date).AddDays(-1) | Get-Date -Format "yyyy-MM-dd")
$ZipDaysCriteria = $((Get-Date).AddDays(-2) | Get-Date -Format "yyyy-MM-dd")

$CurrentTimeStamp= (Get-Date -UFormat "%Y-%m-%d %r %Z" | ForEach-Object { $_ -replace ":", "-" } | ForEach-Object { $_ -replace " ", "_" })    
$LogFileOutputPath = $PSScriptRoot+ "\logs\zip_" +  $CurrentTimeStamp + ".log"

$LogFilesSatisfytingCriteria = Get-ChildItem -File –Path "$LogFilesPath"  | Where-Object { $_.Name.StartsWith("$LogDaysCriteria") -and $_.Name.EndsWith("log") } 
write-host "Started Log Monitoring Script"
write-output "Started Log Monitoring Script" | Out-File -FilePath $LogFileOutputPath -Append

if($LogFilesSatisfytingCriteria -ne $Null ){
    write-output "Files which are added into the zip files will be ..." | Out-File -FilePath $LogFileOutputPath -Append
    write-output $LogFilesSatisfytingCriteria | Out-File -FilePath $LogFileOutputPath -Append

    $ZipFileToSavePath = $( "$ZipFilesPath" + "$LogDaysCriteria" + ".zip")
        $FileExists = Test-Path $ZipFileToSavePath
        if ($FileExists -eq $True) {
            Write-output "File already exists"| Out-File -FilePath $LogFileOutputPath -Append
            $ZipFileToSavePath = $( "$ZipFilesPath" + "$LogDaysCriteria" + "$(Get-Date -UFormat '%r %Z' |  ForEach-Object { $_ -replace ':', '-' } | ForEach-Object { $_ -replace ' ', '_' })" + ".zip" )
        }
    write-output "Starting compressing process for $ZipFileToSavePath" | Out-File -FilePath $LogFileOutputPath -Append
    $LogFilesSatisfytingCriteria | Compress-Archive -DestinationPath "$ZipFileToSavePath"
    write-output "Ended compressing process for $ZipFileToSavePath" | Out-File -FilePath $LogFileOutputPath -Append
}else{
    Write-Output "Unable to find any log files for date $LogDaysCriteria " | Out-File -FilePath $LogFileOutputPath -Append
}

$ZipFilesSatisfytingCriteria = Get-ChildItem -File –Path "$ZipFilesPath"  | Where-Object { $_.Name.StartsWith("$ZipDaysCriteria") -and $_.Name.EndsWith("zip") } 

if($ZipFilesSatisfytingCriteria -ne $Null ){

    write-output "Files which will be deleted are ..." | Out-File -FilePath $LogFileOutputPath -Append
    write-output $ZipFilesSatisfytingCriteria | Out-File -FilePath $LogFileOutputPath -Append
    $ZipFilesSatisfytingCriteria |  ForEach-Object { $_.Delete() }
    write-output "Ended deleting process for $ZipFileToDeletePath" | Out-File -FilePath $LogFileOutputPath -Append

}else{
    Write-Output "Unable to find any zip files for date $ZipDaysCriteria " | Out-File -FilePath $LogFileOutputPath -Append
}

write-output "Executed Successfully Log Monitoring Script" | Out-File -FilePath $LogFileOutputPath -Append
write-host "Executed Successfully Log Monitoring Script"