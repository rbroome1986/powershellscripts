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

<# Start Script #>
#Import the CSV file for creating users
$UserFile = Get-Item "\\ALV-FS01\NewUsers\newusr.csv"
$UserList = Import-csv $UserFile


#Set password for users
$securepassword = ConvertTo-SecureString "Password1234" -AsPlainText -Force
import-module activedirectory

#Create the user
$userlist
ForEach ($user in $userlist){
 $fname = $user.firstname
 $lname = $user.lastname
 $FInitial = $fname.substring(0,1)
 $ext = $user.ext
 $department = $user.department
 $manager = Get-ADUser -Filter 'name -like "$._manager"' -Properties * | select samaccountname
 $title = $user.jobtitle
 
 #$InternOrStaff = $Person.InternOrStaff
 #$Department = $Person.Department
 #$Ext = $Person.Extension

 #Create variables based on name
 $username = $FInitial + $lname + "@alvis180.org"
 $SAM = $FInitial + $lname
 $email = $fname + "." +$lname + "@alvis180.org"
 $email2 = $SAM + "@alvis180.org"
 $driveletter = "H:"
 $user = Get-ADUser -Filter LDAPFilter "(sAMAccountName=$SAM)"

 #Set OU based on if they're an intern or staff just as an example. You can put whatever in here
 #if ($InternOrStaff -eq "I") { $Path = 'OU=ARCUsers,DC=internal,DC=alvis180.org,DC=com'}
 #if ($InternOrStaff -eq "S") { $Path = '<Enter OU Here ex: (OU=Test,OU=Company,DC=hmbnet,DC=com)>'}
 $Path = 'OU=TEST,DC=internal,DC=alvis.local,DC=com'
 }


 #check to see if the user already exists
 if($user -ne $null){"User $SAM already exists."}
 else{

  #Actually Creating the user
  New-ADUser -Name $username -Displayname $username -GivenName $fname -Surname $lname -SamAccountName $SAM `
  -UserPrincipalName $username -AccountPassword $securepassword -EmailAddress $email  `
  -manager $manager -OfficePhone $ext -department $department -ChangePasswordAtLogon $True `
  -Path $Path -homedrive $driveletter -HomeDirectory "\\ALV-VMHOST2\HomeFolders\$SAM" -PassThru | Disable-ADAccount
  Write-Host "User $username created"

  #Set user attributes
  set-aduser -identity $SAM -Add @{ProxyAddresses="SMTP:"+$email}
  set-aduser -identity $SAM -Add @{ProxyAddresses="smtp:"+$email2}
  }
#beep boop#
Write-Host "Beep boop user creation finished" -confirm
#delete csv when finished#
Remove-item "\\ARCWOWFS1.internal.alvis180.org\New User Input\newusr.csv"
#beep boop#
Write-host "Beep boop the CSV is GONE" -confirm