$LogFilesPath = $PSScriptRoot+ "\logs\" 
$ZipFilesPath = $PSScriptRoot+ "\zips\"

$LogToZipArchivalDays=-5
$ZipDeletionDays=-30

$LogToZipArchivalDate=$((Get-Date).AddMinutes($LogToZipArchivalDays))
$ZipDeletionDate=$((Get-Date).AddMinutes($ZipDeletionDays))

$LogToZipArchivalDateToPrint = $( $LogToZipArchivalDate| Get-Date -Format "yyyy-MM-dd")
$ZipDeletionDateToPrint = $($ZipDeletionDate | Get-Date -Format "yyyy-MM-dd")


$CurrentTimeStamp= (Get-Date -UFormat "%Y-%m-%d %r %Z" | ForEach-Object { $_ -replace ":", "-" } | ForEach-Object { $_ -replace " ", "_" })    
$LogFileOutputPath = $PSScriptRoot+ "\logs\zip_" +  $CurrentTimeStamp + ".log"

$LogFilesSatisfytingCriteria = Get-ChildItem -File -Path "$LogFilesPath"  | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $LogToZipArchivalDate -and $_.Name.EndsWith("log") } 
write-host "Started Log Monitoring Script" + $CurrentTimeStamp
write-output "Started Log Monitoring Script $CurrentTimeStamp" | Out-File -FilePath $LogFileOutputPath -Append

if($LogFilesSatisfytingCriteria -ne $Null ){
    write-output "Files which are added into the zip files will be ..." | Out-File -FilePath $LogFileOutputPath -Append
    write-output $LogFilesSatisfytingCriteria | Out-File -FilePath $LogFileOutputPath -Append

    $ZipFileToSavePath = $( "$ZipFilesPath" + "$LogToZipArchivalDateToPrint" + ".zip")
        $FileExists = Test-Path $ZipFileToSavePath
        if ($FileExists -eq $True) {
            Write-output "File already exists"| Out-File -FilePath $LogFileOutputPath -Append
            $ZipFileToSavePath = $( "$ZipFilesPath" + "$LogToZipArchivalDateToPrint" + "$(Get-Date -UFormat '%r %Z' |  ForEach-Object { $_ -replace ':', '-' } | ForEach-Object { $_ -replace ' ', '_' })" + ".zip" )
        }
    write-output "Starting compressing process for $ZipFileToSavePath" | Out-File -FilePath $LogFileOutputPath -Append
    $LogFilesSatisfytingCriteria | Compress-Archive -DestinationPath "$ZipFileToSavePath"
    write-output "Ended compressing process for $ZipFileToSavePath" | Out-File -FilePath $LogFileOutputPath -Append

    $LogFilesSatisfytingCriteria |  ForEach-Object { $_.Delete() }

}else{
    Write-Output "Unable to find any log files older than date $LogToZipArchivalDateToPrint " | Out-File -FilePath $LogFileOutputPath -Append
}

$ZipFilesSatisfytingCriteria = Get-ChildItem -File -Path "$ZipFilesPath"  | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $ZipDeletionDate -and $_.Name.EndsWith("zip") } 

if($ZipFilesSatisfytingCriteria -ne $Null ){

    write-output "Files which will be deleted are ..." | Out-File -FilePath $LogFileOutputPath -Append
    write-output $ZipFilesSatisfytingCriteria | Out-File -FilePath $LogFileOutputPath -Append
    $ZipFilesSatisfytingCriteria |  ForEach-Object { $_.Delete() }
    write-output "Ended deleting process for $ZipFileToDeletePath" | Out-File -FilePath $LogFileOutputPath -Append

}else{
    Write-Output "Unable to find any zip files for date $ZipDeletionDateToPrint " | Out-File -FilePath $LogFileOutputPath -Append
}

write-output "Executed Successfully Log Monitoring Script" | Out-File -FilePath $LogFileOutputPath -Append
write-host "Executed Successfully Log Monitoring Script"