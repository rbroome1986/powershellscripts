#Script for determining number of items in users mailboxes from certain date range
#Gets date for CSV formatting
$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('yyyy--mm-dd-hhmmss')
#Require for local execution
Set-ExecutionPolicy RemoteSigned
#Must enter admin creds with proper Exchange permissions or this WILL NOT WORK! If unsure about RABC permisissions get with Ryan.
$UserCredential = Get-Credential
#Connection to O365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Connection to O365
Import-PSSession $Session -DisableNameChecking
#Script below searchs all mailboxes and exports csv results for all empty folders. 
Get-Mailbox | Get-MailboxFolderStatistics | Where {$_.ItemsInFolder -eq '0'}  | Where {$_.FolderType -eq 'User Created'} | Select -Property Identity, FolderPath, FolderType, FolderSize, ItemsInFolder |  Export-CSV -Path "$PSScriptRoot\FolderQuery_$currentdate.csv"