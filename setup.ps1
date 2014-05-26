[System.Reflection.Assembly]::`
  LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

$profilepath = Split-Path $PROFILE -parent

if(Test-Path $profilepath) {
  Write-Warning "$profilepath exists and it will be deleted"
  Remove-Item -Recurse -Force $profilepath
}

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
  git clone https://github.com/ogman/PSModules.git $profilepath
} else {
  DownloadZippedProfile
}

if(-not $env:Path.tolower().Contains("chocolatey")) {
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
  $env:PATH="{0};{1}\chocolatey\bin" -f $env:PATH,$env:SystemDrive
}

cinst vim

Write-Host "Creating .vimrc hardlink"
if(Test-Path "$env:USERPROFILE\.vimrc") {
  Remove-Item -Force "$env:USERPROFILE\.vimrc"
}
cmd /c mklink /H $env:USERPROFILE\.vimrc $profilepath\.vimrc | Out-Null
Write-Host "Done"

Write-Host "Creating vimfiles junction"
if(Test-Path "$env:USERPROFILE\vimfiles") {
  Remove-Item -Recurse -Force "$env:USERPROFILE\vimfiles"
}
cmd /c mklink /J $env:USERPROFILE\vimfiles $profilepath\vimfiles
Write-Host "Done"

