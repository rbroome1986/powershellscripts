#import csv
import-csv "C:\powershell\info.csv" | ForEach-Object {Get-ADUser -Filter 'name -like "$._displayname"' -Properties *} | select samaccountname | export-csv .\samaccountnames.csv