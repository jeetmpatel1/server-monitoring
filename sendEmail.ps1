$EmailTo = "email@gmail.com"  
$EmailFrom = "email@gmail.com"  
$Subject = "Test Subject"  
$Body = "<h1>Test Body</h1>" 
$SMTPServer = "smtp.gmail.com" 
 
write-host "------------------Try with Send-MailMessage"

Send-MailMessage  -SmtpServer $SMTPServer -To  $EmailTo -From $EmailFrom -Subject $Subject -Body $Body

write-host "------------------Try with Send-MailMessage completed"


write-host "------------------Try with SmtpClient"

$filenameAndPath = "C:\Users\jmpatel\Desktop\Know.txt"  
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
$SMTPMessage.Attachments.Add($attachment)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
#$SMTPClient.EnableSsl = $true 
<# in the below line, password is the app password which can be retrieved from below stack overflow answer.
https://stackoverflow.com/questions/50078851/windows-powershell-smtp-server-requires-a-secure-connection/58964001#58964001
#>
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("email@gmail.com", "lggcvgwwofgcsizr");   
$SMTPClient.Send($SMTPMessage)

write-host "------------------Try with SmtpClient completed"