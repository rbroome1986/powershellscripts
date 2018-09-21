#variable for username/identity
$user = read-host "input user identity"
#command just to GET the information
get-aduser -identity $user