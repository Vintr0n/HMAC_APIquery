#This is for the purposes of running from SSMS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

Clear-Content "\\server\location\Cookies.txt"
Clear-Content "\\server\location\HMAC.txt"

$secret = 'secretkeygoeshere'

#Things that make up the message string (to be used as part of the HMAC)
$key = '512'
$username = 'usernamehere'
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

$message = $username + $key + $timestamp

$hmacsha = New-Object System.Security.Cryptography.HMACSHA512
$hmacsha.key = [Text.Encoding]::ASCII.GetBytes($secret)
$signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
$signature = [Convert]::ToBase64String($signature)

$signature | Out-File '\\server\location\\HMAC.txt'

$url = 'https://website.domain/api/hmacendpoint?'+'username='+$username+'&key='+$key+'&timestamp='+$timestamp+'&hmac='+$signature


$webrequest = Invoke-WebRequest -Uri $url -SessionVariable websession 
$cookies = $websession.Cookies.GetCookies($url) 


foreach ($cookie in $cookies) { 
    [System.IO.File]::AppendAllText("\\server\location\Cookies.txt", "$($cookie.name)=$($cookie.value);", [System.Text.Encoding]::Unicode)
}


$original_file = '\\server\location\Cookies.txt'
$destination_file =  '\\server\location\ookies.txt'
(Get-Content $original_file) | Foreach-Object {
    $_ -replace 's:', 's%3A' `
       -replace ''+'', '%2B' `
       -replace '/', '%2F' `
    } | Set-Content $destination_file

