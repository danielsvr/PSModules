# TODO
#
# Create a runcom.cmd (like bashrc in linux)
# see http://superuser.com/questions/144347/is-there-windows-equivalent-of-the-bashrc-file-in-linux
#
# make cmd prompt nicer 
# http://www.hanselman.com/blog/ABetterPROMPTForCMDEXEOrCoolPromptEnvironmentVariablesAndANiceTransparentMultiprompt.aspx


[System.Reflection.Assembly]::`
  LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

$profilepath = Split-Path $PROFILE -parent

Function DownloadZippedProfile {
    # temporary redirect
    # $profilepath = ("{0}_tmp" -f $profilepath)
    # Write-Host $profilepath

    $tempPath = $env:TEMP

    $tempProfileZip = "$tempPath\PSProfile.zip"
    $tempProfileUnzip = "$tempPath\PSProfile"
    # Write-Host $tempProfileZip

    if(Test-Path $tempProfileZip) {
      Write-Warning "$tempProfileZip exixts and it will be removed"
      Remove-Item $tempProfileZip
    }

    # fetch profile
    Write-Host "Donwloading https://github.com/ogman/PSModules/archive/master.zip"
    Write-Host "         to $tempProfileZip"
    (New-Object System.Net.WebClient).`
      DownloadFile("https://github.com/ogman/PSModules/archive/master.zip", `
                 $tempProfileZip)
    Write-Host "Done"

    Write-Host "Unziping $tempProfileZip"
    Write-Host "      to $tempProfileUnzip"


    Remove-Item -Recurse -Force $tempProfileUnzip -ErrorAction SilentlyContinue
    [System.IO.Compression.ZipFile]::`
      ExtractToDirectory($tempProfileZip, $tempProfileUnzip)
    Write-Host "Done"

    Write-Host "Moving unziped content to $profilepath"
    Move-Item "$tempProfileUnzip\PSModules-master" $profilepath
    Write-Host "Done"
}

$gitExists = Get-Command git -ErrorAction SilentlyContinue
if(-not ($gitExists -eq $null)) {
  if(Test-Path $profilepath\.git) {
    Write-Host "profile is already a git repo. updating..."
    git pull
  } else {
    if(Test-Path $profilepath) {
      Write-Warning "$profilepath exists and it will be deleted"
      Remove-Item -Recurse -Force $profilepath
    }
    git clone https://github.com/ogman/PSModules.git $profilepath
  }
} else {
  if(Test-Path $profilepath) {
    Write-Warning "$profilepath exists and it will be deleted"
    Remove-Item -Recurse -Force $profilepath
  }
  DownloadZippedProfile
}

if(-not $env:Path.tolower().Contains("chocolatey")) {
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
  $env:PATH="{0};{1}\chocolatey\bin" -f $env:PATH,$env:SystemDrive
}

if(-not ((Get-Command vim -ErrorAction SilentlyContinue) -eq $null)) {
  cinst vim
}

Write-Host "Creating .vimrc softlink"
if(Test-Path "$env:USERPROFILE\.vimrc") {
  Remove-Item -Force "$env:USERPROFILE\.vimrc"
}

start cmd `
  -ArgumentList @("/c","mklink $env:USERPROFILE\.vimrc $profilepath\.vimrc") `
  -WindowStyle Hidden `
  -verb runas `
  -ErrorAction SilentlyContinue | Out-Host
Write-Host "Done"

Write-Host "Creating vimfiles junction"
if(Test-Path "$env:USERPROFILE\vimfiles") {
  $junction = Get-Item "$env:USERPROFILE\vimfiles"
  $junction.Delete()
}

cmd /c mklink /J $env:USERPROFILE\vimfiles $profilepath\vimfiles

Write-Host "Done"
Write-Host " "

#setup cmd.exe
$runcomcontent = @'
@echo off
SET PROMPT=%USERNAME%@%COMPUTERNAME%$S$P$_$$$G$S

IF EXIST %USERPROFILE%\runcom.cmd (
  %USERPROFILE%\runcom.cmd
)
'@

$asAdminCommand = @"
Set-Location 'HKLM:\Software\Microsoft\Command Processor'; 
Set-ItemProperty . 'AutoRun' 'C:\Windows\runcom.cmd';
'$runcomcontent' | Out-File C:\Windows\runcom.cmd -Encoding ASCII
"@

start powershell `
  -WindowStyle Hidden `
  -verb runas `
  -ArgumentList "-Command",$asAdminCommand `
  | Out-Host

Write-Host "Restart your shells."
Write-Host " "

