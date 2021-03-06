# powershell utility functions
#

$profilepath = Split-Path $PROFILE -parent

$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
Push-Location $PSScriptRoot
. .\profile-util.ps1
. .\ini-files.ps1
Pop-Location

function Invoke-PreservingExitCode {
<#
.SYNOPSIS
    An utility function for executing a scriptblock while preserving the exit code.
.EXAMPLE
    Invoke-PreservingExitCode { param($p); cd ..\$p } -arguments $myarg
#>
param(
  [scriptblock] $script,
  [array] $arguments
)
  $realLASTEXITCODE = $LASTEXITCODE
  
  try {
    $result = Invoke-Command -scriptblock $script -argumentlist $arguments
  } finally {
    $Global:LASTEXITCODE = $realLASTEXITCODE
  }

  return $result
}

function Get-CommandPath {
param(
  [Parameter(Mandatory=$true)][string]$command
)

  $cmd = Get-Command $command
  if(-not($cmd.CommandType -eq "Application")){
    Write-Warning "Command is not an application"
  }
  return "$($cmd.Path)"
}


Set-Alias rc                  Restore-AllModules
Set-Alias rstcon              Restore-AllModules
Set-Alias which               Get-CommandPath

Export-ModuleMember -Function Invoke-PreservingExitCode
Export-ModuleMember -Function Restore-AllModules
Export-ModuleMember -Function Restore-Profile
Export-ModuleMember -Function Update-Profile
Export-ModuleMember -Function Get-CommandPath

Export-ModuleMember -Alias    rc
Export-ModuleMember -Alias    rstcon
Export-ModuleMember -Alias    which

Export-ModuleMember -Variable profilepath


