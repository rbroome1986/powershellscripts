#Script for determining number of items in users mailboxes from certain date range
#Gets date for CSV formatting
$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('yyyy-dd-hhmmss')
#email accounts we're deleting from
$username = read-host "Enter username for email deletion"
#Require for local execution
Set-ExecutionPolicy RemoteSigned
#Must enter admin creds with proper Exchange permissions or this WILL NOT WORK! If unsure about RABC permisissions get with Ryan.
$UserCredential = Get-Credential
#Connection to O365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Connection to O365
Import-PSSession $Session -DisableNameChecking
#Script below searchs all mailboxes and deletes for date range. 
Get-Mailbox -identity $username | Search-Mailbox -searchQuery 'Received:01/01/1990..12/31/2017 OR Sent:01/01/1990..12/31/2017' -deletecontent | Export-CSV -Path "$PSScriptRoot\DateQuery_$currentdate.csv"