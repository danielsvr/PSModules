$profilepath = Split-Path $PROFILE -parent
powershell -NoProfile -Command "cd $profilepath; git pull"
$devenv   = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
$devenv10 = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
$devenv11 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"

Set-Alias devenv "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
Set-Alias devenv10 "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
Set-Alias devenv11 "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
Get-Module -ListAvailable | Import-Module
