#
##
## opening keepass with a default db and a encrypted stored password
##
#
Function Invoke-KeePass {
param(
[switch]$NoProfile,
[string]$db = "$($env:USERONEDRIVE)\lockInfo\MyKees.kdbx"
)
$keepass = Get-Command "keepass.exe" -ErrorAction Ignore
if(-not $keepass) {
  $keepass = Get-Command "C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe"
}
if(-not $keepass) {
  $keepass = Get-Command "C:\Program Files\KeePass Password Safe 2\KeePass.exe"
}
if($NoProfile.IsPresent) {
  start $keepass
  return
}

$kpass = "$profilepath\.data\.kpass"

if(-not (Test-Path $kpass)) {
  $kpass ="$($env:USERPROFILE)\.kpass"
}

if(-not (Test-Path $kpass)) {
  start "$($keepass.Path)"
  return
}

$securePw =(Get-Content -Path $kpass | ConvertTo-SecureString);
$pw = $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePw)))

if($env:KEEPASSDEFAULTDB -eq $null) {
  Write-Warning "Failed to auto-detect db."
  Write-Verbose "Environment vartiable KEEPASSDEFAULTDB is not set."

  start "$($keepass.Path)"
  return
}

if(Test-Path $env:USERONEDRIVE) {
  $db = "$($env:USERONEDRIVE)\$($env:KEEPASSDEFAULTDB)"
}

if(-not (Test-Path $db)) {
  Write-Verbose """$db"" not found."
  $db = "$($env:USERPROFILE)\OneDriveHome\OneDrive\$($env:KEEPASSDEFAULTDB)"
}

if(-not (Test-Path $db)) {
  Write-Verbose """$db"" not found."
  $db = "$($env:USERPROFILE)\SkyDrive\$($env:KEEPASSDEFAULTDB)"
}

if(-not (Test-Path $db)) {
  Write-Verbose """$db"" not found."
  Write-Warning "Failed to auto-detect db."

  start "$($keepass.Path)"
  return
}

start "$($keepass.Path)" -ArgumentList ($db, "-pw:$pw")

}


#
##
## Saving an encrypted password in a profile file
##
#
Function Set-KeePass {
param(
[string]$password,
[string]$Path = "$profilepath\.data\.kpass" 
)

ConvertTo-SecureString $password -AsPlainText -Force | ConvertFrom-SecureString | Out-File $Path

}

Set-Alias keepass Invoke-KeePass
Set-Alias kp Invoke-KeePass

Export-ModuleMember -Function Invoke-KeePass
Export-ModuleMember -Function Set-KeePass
Export-ModuleMember -Alias keepass
Export-ModuleMember -Alias kp

