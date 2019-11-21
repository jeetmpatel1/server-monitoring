
    $EmailTo = "email@gmail.com"  
    $EmailFrom = "email@gmail.com"  
    $Subject = "zx"  
    $Body = "Test Body" 
    $SMTPServer = "smtp.gmail.com" 
    $filenameAndPath = "C:\Users\jmpatel\Desktop\Know.txt"  
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
    $SMTPMessage.Attachments.Add($attachment)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    <# in the below line, password is the app password which can be retrieved from below stack overflow answer.
    https://stackoverflow.com/questions/50078851/windows-powershell-smtp-server-requires-a-secure-connection/58964001#58964001
    #>
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("email@gmail.com", "lggcvgwwofgcsizr");   
    $SMTPClient.Send($SMTPMessage)