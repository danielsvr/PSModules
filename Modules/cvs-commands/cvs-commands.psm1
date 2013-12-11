# a group of functions that ease the usage of svn, 
# git or git-svn type repositories
#
# NOTE: there will be others if I encounter :)

# using
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath
. $ScriptDir\cvs-debug.ps1
. $ScriptDir\cvs-utils.ps1
. $ScriptDir\svn-utils.ps1
. $ScriptDir\git-utils.ps1
# end-using


$global:CvsSettings = New-Object PSObject -Property @{
  # Enables/Disables debug messages
  Debug              = $false

  # git related and configurable information
  GitHiddenDirectory = ".git"
  GitToolPath        = $null
  GitTool            = "git"

  # svn related and configurable information
  SvnHiddenDirectory = ".svn"
  SvnToolPath        = $null
  SvnTool            = "svn"
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

Set-Alias update Update-Repository
Set-Alias commit Confirm-Changes

Export-ModuleMember -Function Update-Repository
Export-ModuleMember -Alias update
Export-ModuleMember -Function Confirm-Changes
Export-ModuleMember -Alias commit
