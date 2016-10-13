# a group of functions that ease the usage of svn, 
# git or git-svn type repositories
#
# NOTE: there will be others if I encounter :)

# using
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath
. $ScriptDir\vcs-debug.ps1
. $ScriptDir\vcs-utils.ps1
. $ScriptDir\svn-utils.ps1
. $ScriptDir\git-utils.ps1
# end-using

if($global:VcsSettings -eq $null) {
  $global:VcsSettings = New-Object PSObject
}

# Enables/Disables debug messages
if($global:VcsSettings.PSObject.Properties.Match('Debug').Count -gt 0) {
  $global:VcsSettings.Debug = $false
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name Debug -Value $false
}

# git related and configurable information
if($global:VcsSettings.PSObject.Properties.Match('GitHiddenDirectory').Count -gt 0) {
  $global:VcsSettings.GitHiddenDirectory = ".git"
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name GitHiddenDirectory -Value ".git"
}
if($global:VcsSettings.PSObject.Properties.Match('GitToolPath').Count -gt 0) {
  $global:VcsSettings.GitToolPath = $null
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name GitToolPath -Value $null
}
if($global:VcsSettings.PSObject.Properties.Match('GitTool').Count -gt 0) {
  $global:VcsSettings.GitTool = "git"
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name GitTool -Value "git"
}
if($global:VcsSettings.PSObject.Properties.Match('IsGitInstalled').Count -gt 0) {
  $global:VcsSettings.IsGitInstalled = (-not ((Get-Command "git" -ErrorAction SilentlyContinue) -eq $null))
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name IsGitInstalled -Value (-not ((Get-Command "git" -ErrorAction SilentlyContinue) -eq $null))
}

# svn related and configurable information
if($global:VcsSettings.PSObject.Properties.Match('SvnHiddenDirectory').Count -gt 0) {
  $global:VcsSettings.SvnHiddenDirectory = ".svn"
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name SvnHiddenDirectory -Value ".svn"
}
if($global:VcsSettings.PSObject.Properties.Match('SvnToolPath').Count -gt 0) {
  $global:VcsSettings.SvnToolPath = $null
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name SvnToolPath -Value $null
}
if($global:VcsSettings.PSObject.Properties.Match('SvnTool').Count -gt 0) {
  $global:VcsSettings.SvnTool = "svn"
} else {
  $global:VcsSettings | Add-Member NoteProperty `
  -Name SvnTool -Value "svn"
}

function Update-Repository {
<#
.SYNOPSIS
    Updates the source control repository that resides at current 
    location or at provided path. It can be a svn, git or git-svn
    repository.
.EXAMPLE
    Update-Repository -Path c:\path\to\repo
.EXAMPLE
    Update-Repository 
.PARAMETER path
    The path to the repository. If the parameter is missing 
    then te execution location is used to discover the 
    repository.
#>
  param(
    [Parameter(Mandatory=$false, Position=0)][string] $path
  )

  if(-not $path) {
    $path = Get-Item "." -Force
  }

  $repoInfo = Get-RepositoryInfo $path

  $repoType = $repoInfo.Type
  $path = $repoInfo.RootDirectory

  Write-Dbg "$repoType repository discoverd."
  switch($repoType) {
    "svn"     { Update-SvnRepository $path }
    "git"     { Update-GitRepository $path }
    "git-svn" { Update-GitSvnRepository $path }
    default   { throw "unknown repositoty type" }
  }
}

function Confirm-Changes{
<#
.SYNOPSIS
.EXAMPLE
.PARAMETER path
#>
  param([Parameter(Mandatory=$false)][string]$path)

  if(-not $path) {
    $path = Get-Item "." -Force
  }

  $repoInfo = Get-RepositoryInfo $path

  $repoType = $repoInfo.Type
  $path = $repoInfo.RootDirectory

  Write-Dbg "$repoType repository discoverd."
  switch -regex ($repoType) {
    "^svn$"   { Confirm-SvnChanges $path }
    "^git.*$" { Confirm-GitChanges $path }
    default   { throw "unknown repositoty type" }
  }
}

function Get-RepositoryInfo {
<#
.SYNOPSIS
    Gets the information of the repository that resides at the 
    specified location
.EXAMPLE
    Get-RepositoryType c:\path\to\repo
.PARAMETER path
    The path into the repository. It can be the root directory 
    or one of its sub-directories
.RETURNS
    A PSObject the holds the type and root directory. The type
    is described by a string that has one of the values: 
    "svn", "git" or "git-svn"
#>
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $path
  )

  $result = New-Object PSObject -Property @{
    Type          = "unknown"
    RootDirectory = $null
  }

  $svnRootDir = Get-SvnRepositoryRootLocation $path

  if($svnRootDir){
    $result.Type = "svn"
    $result.RootDirectory = $svnRootDir
    
    return $result
  }

  $gitRootDir = Get-GitRepositoryRootLocation $path

  if($gitRootDir){
    $result.Type = "git"
    $result.RootDirectory = $gitRootDir

    $isGitSvnRepository = Test-GitSvnRepository $path
    if($isGitSvnRepository -eq $true){
      $result.Type = "git-svn"
    }
    
    return $result
  }
  
  return $result
}

function Register-PoshGit {

  if($Global:VcsSettings.IsGitInstalled) {
    $Global:VcsPromptStatuses = @()
    Import-Module posh-git
    Enable-GitColors
  } else {
    $Global:GitPromptSettings = New-Object PSObject -Property @{
      DefaultForegroundColor    = $Host.UI.RawUI.ForegroundColor
    }
    $Global:GitMissing = $true
  }
}

function Get-VcsStatus {
  $poshGitModule= Get-Module posh-git
  if($poshGitModule -eq $null) {
    Import-Module posh-git -ErrorAction SilentlyContinue
    $poshGitModule = Get-Module posh-git
    if($poshGitModule -eq $null) {
      $pr = "`n$(Get-Date)"
      $pr = "`n"+ [Environment]::UserName + "@" + [Environment]::MachineName + " "
      $pr = $pr + $pwd.ProviderPath
      return $pr + "`n$> "
    }    
  }

  Invoke-PreservingExitCode({
    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host " "
    Write-Host "$(Get-Date)"
    Write-Host([Environment]::UserName + `
              "@" + [Environment]::MachineName + " ") `
              -nonewline -foregroundcolor "DarkGreen"

    Write-Host($pwd.ProviderPath) -nonewline -foregroundcolor "Gray"

    if($Global:VcsSettings.IsGitInstalled) {
      Write-VcsStatus
    }
    Write-Host " "
  })

  return "$> "
}

Set-Alias update Update-Repository
Set-Alias commit Confirm-Changes

Export-ModuleMember -Function Update-Repository
Export-ModuleMember -Function Register-PoshGit
Export-ModuleMember -Function Get-VcsStatus
Export-ModuleMember -Alias update
Export-ModuleMember -Function Confirm-Changes
Export-ModuleMember -Alias commit
