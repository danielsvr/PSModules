$profilepath = Split-Path $PROFILE -parent

function Update-Profile(){
    $gitFetchFile = Get-Item $profilepath\.git\FETCH_HEAD
    $lastGitFetch = Get-Date ($gitFetchFile).LastWriteTime -Uformat %D
    $today = Get-Date -UFormat %D
    if(-not($lastGitFetch -eq $today)){
	    powershell -NoProfile -Command "cd $profilepath; git pull"
    }
}

Update-Profile
	
$notepad  = "C:\Program Files (x86)\Notepad++\notepad++.exe"
$devenv   = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
$devenv10 = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
$devenv11 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
$mstest   = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\mstest.exe"
$mstest11 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\mstest.exe"
$msbuild  = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
$msbuild4 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"

Set-Alias notepad  "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias devenv   "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
Set-Alias devenv10 "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
Set-Alias devenv11 "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
Set-Alias msbuild  "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
Set-Alias mstest   "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\mstest.exe"

Import-Module posh-git

# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
	
	Write-Host " "
	Write-Host([Environment]::UserName + "@" + [Environment]::MachineName + " ") -nonewline -foregroundcolor "DarkGreen"
    Write-Host($pwd.ProviderPath) -nonewline -foregroundcolor "Gray"

    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
	Write-Host " "
	return "$> "
}

Enable-GitColors

Pop-Location

#Start-SshAgent -Quiet