# ([Console]::OutputEncoding = [System.Text.Encoding]::ASCII) | Out-NULL
# ($OutputEncoding = [Console]::OutputEncoding) | Out-NULL

Import-Module cvs-commands
Import-Module ProfileUtil

$profilepath = Split-Path $PROFILE -parent

$gitExists = -not ((Get-Command git -ErrorAction SilentlyContinue) -eq $null)

if($gitExists) {
  Update-Profile
  Import-Module posh-git
} else {
  $global:GitPromptSettings = New-Object PSObject -Property @{
    DefaultForegroundColor    = $Host.UI.RawUI.ForegroundColor
  }
  $Global:GitMissing = $true
}

$notepad  = "C:\Program Files (x86)\Notepad++\notepad++.exe"
$devenv   = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"
$devenv10 = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
$devenv11 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
$devenv12 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"
$mstest   = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\mstest.exe"
$mstest11 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\mstest.exe"
$mstest12 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\mstest.exe"
$msbuild  = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
$msbuild4 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
$procex = "C:\Chocolatey\lib\procexp.15.13\tools\procexp.exe"

Set-Alias notepad  "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias devenv   "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
Set-Alias devenv10 "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
Set-Alias devenv11 "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
Set-Alias msbuild  "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
Set-Alias mstest   "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\mstest.exe"
Set-Alias procex   "C:\Chocolatey\lib\procexp.15.13\tools\procexp.exe"
Set-Alias remote   "mstsc"


# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
	
    Write-Host " "
    Write-Host([Environment]::UserName + "@" + [Environment]::MachineName + " ") -nonewline -foregroundcolor "DarkGreen"
    Write-Host($pwd.ProviderPath) -nonewline -foregroundcolor "Gray"

    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    
    if(-not $Global:GitMissing) {
      Write-VcsStatus
    }

    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host " "
    return "$> "
}

if($gitExists) {
  Enable-GitColors
}

Pop-Location

# clean up
Remove-Variable gitExists

# Start-SshAgent -Quiet

# function to help binding exit keyword to an alias
function ex{exit}
Set-Alias :q ex
Set-Alias ^Q ex
