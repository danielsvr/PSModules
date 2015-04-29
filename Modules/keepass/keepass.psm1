Function Invoke-KeePass {
param(
[switch]$NoProfile,
[string]$db = "C:\Users\IBM_ADMIN\OneDriveHome\OneDrive\lockInfo\MyKees.kdbx"
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

$kpass ="$($env:USERPROFILE)\.kpass" 

if(-not (Test-Path $kpass)) {
  $kpass = "$profilepath\.kpass"
}

if(-not (Test-Path $kpass)) {
  start "$($keepass.Path)"
  return
}

$securePw =(Get-Content -Path $kpass | ConvertTo-SecureString);
$pw = $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePw)))

start "$($keepass.Path)" -ArgumentList ($db, "-pw:$pw")

}

Function Set-KeePass {
param(
[string]$password,
[string]$Path = "$($env:USERPROFILE)\.kpass" 
)

ConvertTo-SecureString $password -AsPlainText -Force | ConvertFrom-SecureString | Out-File $Path

}

Set-Alias keepass Invoke-KeePass
Set-Alias kp Invoke-KeePass

Export-ModuleMember -Function Invoke-KeePass
Export-ModuleMember -Function Set-KeePass
Export-ModuleMember -Alias keepass
Export-ModuleMember -Alias kp

