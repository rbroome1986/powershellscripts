<#	
	.NOTES
	===========================================================================
	 Version        2.4
     Created on:   	1/25/18
	 Created by:   	Cory Landis
     Edit by at some points: Ryan Broome
	 Filename:     	NewUserScript.ps1
	===========================================================================
	.DESCRIPTION
		Creates users from a CSV File and sets password. Creates user share and assigns permissions.


         -----------  
         -Changelog-
         -----------
                          
 1-25-18 Created: Makes new user and  
 creates Home Folder.                 
                                      
 1-29-18 Modified script to check if  
 user already exists before it does   
 its work.

 1-29-18
 Added QoL updates

 5/24/18
 Generalized Script for use at different companies

 7/9/18 Specified for ARC Industries

 9/24/18
 Changed UPN to email2.
#>
import-module activedirectory
<# Start Script #>
#Import the CSV file for creating users
$UserList = Import-csv "\\ARCWOWFS1.internal.arcind.com\New User Input\newusr.csv"


#Set password for users
$securepassword = ConvertTo-SecureString "Password1234" -AsPlainText -Force


#Create the user
$userlist | ForEach {
 $fname = $_.firstname
 $lname = $_.lastname
 $FInitial = $_.firstname.substring(0,1)
 $ext = $_.ext
 $department = $_.department
 $manager = Get-ADUser -Filter 'name -like "$._manager"' -Properties * | select samaccountname
 $title = $_.jobtitle
 $Displayname = "$fname $lname"
 #$InternOrStaff = $Person.InternOrStaff
 #$Department = $Person.Department
 #$Ext = $Person.Extension

 #Create variables based on name
 $SAM = $FInitial + $lname
 $SAM2 = $Finitial + $lname + "2"
 $username = $SAM + "@arcind.com"
 $username2 = $SAM2 + "@arcind.com"
 $email = $fname + "." +$lname + "@arcind.com"
 $emaildos = $SAM2 + "@arcind.com"
 $email2 = $SAM + "@arcind.com"
 $driveletter = "H:"

 #Set OU based on if they're an intern or staff just as an example. You can put whatever in here
 #if ($InternOrStaff -eq "I") { $Path = 'OU=ARCUsers,DC=internal,DC=internal.arcind.com,DC=com'}
 #if ($InternOrStaff -eq "S") { $Path = '<Enter OU Here ex: (OU=Test,OU=Company,DC=hmbnet,DC=com)>'}
 $Path = 'OU=ARCUsers,DC=internal,DC=arcind,DC=com'


 #check to see if the user already exists
 if(dsquery user -name $displayname){Write-Host "User $displayname already exists"}
 else{
 if(dsquery user -samid $SAM){
  #Actually Creating the user
  New-ADUser -Name "$fname $lname" -Displayname $displayname -GivenName $fname -Surname $lname -SamAccountName $SAM2 `
  -UserPrincipalName $username2 -AccountPassword $securepassword -EmailAddress $email  `
  -manager $manager -officephone $ext -department $department `
  -Path $Path -homedrive $driveletter -HomeDirectory "\\ARCWOWFS1.internal.arcind.com\HomeFolders\HomeFolders\$SAM" -PassThru | Enable-ADAccount
  Write-Host "User $username 2 created"

  #Set user attributes
  set-aduser -identity $SAM2 -Add @{ProxyAddresses="SMTP:"+$email}
  set-aduser -identity $SAM2 -Add @{ProxyAddresses="smtp:"+ $emaildos}

  #If Ext is populated then set Extension
  if ($Ext){
   set-aduser -identity $SAM2 -Add @{telephoneNumber="$Ext"}
  }
  #Change password on login
  set-aduser -identity $SAM2 -ChangePasswordAtLogon $True
}
 else{

  #Actually Creating the user
  New-ADUser -Name "$fname $lname" -Displayname $displayname -GivenName $fname -Surname $lname -SamAccountName $SAM `
  -UserPrincipalName $username -AccountPassword $securepassword -EmailAddress $email  `
  -manager $manager -officephone $ext -department $department `
  -Path $Path -homedrive $driveletter -HomeDirectory "\\ARCWOWFS1.internal.arcind.com\HomeFolders\HomeFolders\$SAM" -PassThru | Enable-ADAccount
  Write-Host "User $username created"

  #Set user attributes
  set-aduser -identity $SAM -Add @{ProxyAddresses="SMTP:"+$email}
  set-aduser -identity $SAM -Add @{ProxyAddresses="smtp:"+$email2}

  #If Ext is populated then set Extension
  if ($Ext){
   set-aduser -identity $SAM -Add @{telephoneNumber="$Ext"}
  }
  #Change password on login
  set-aduser -identity $SAM -ChangePasswordAtLogon $True

 }
}
}
#beep boop#
Write-Host "Beep boop user creation finished"
#delete csv when finished#
Remove-Item "\\ARCWOWFS1.internal.arcind.com\New User Input\newusr.csv"
#beep boop#
Write-host "Beep boop the CSV is GONE"