
function func_sendReport ([string]$report ) {
	#Send out an email with the names  
	$emailFrom = "admin@dettonville.org"  
	$emailTo = "admin@dettonville.org"  
	$subject = "List of started servers"  
	$smtpServer = "mail1.johnson.local"  
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)  
	$smtp.Send($emailFrom, $emailTo, $subject, $report)  
}

$logFileName = "C:\apps\powershell\logs\poweronvms.log"

$msg = (Get-Content $logFileName) -join "`n"
$msg
func_sendReport $msg
