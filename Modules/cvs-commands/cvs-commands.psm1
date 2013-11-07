# a groups of functions that ease the usage of svn, 
# git or git-svn type repositories
#

# using
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath
. $ScriptDir\cvs-debug.ps1
. $ScriptDir\cvs-utils.ps1
. $ScriptDir\svn-utils.ps1
. $ScriptDir\git-utils.ps1

# end-using


$global:CvsSettings = New-Object PSObject -Property @{
  Debug              = $true
  GitHiddenDirectory = ".git"
}

function Update-Repository{
<#
.SYNOPSIS
    Updates the source control repository that can be a svn, 
    git or git-svn repository.
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

$repoType = Get-RepositoryType $path

Write-Dbg "$repoType repository discoverd."
switch($repoType) {
  "svn"     { Update-SvnRepository $path }
  "git"     { Update-GitRepository $path }
  "git-svn" { Update-GitSvnRepository $path }
  default   { throw "unknown repositoty type" }
}

}

function Get-RepositoryType{
<#
.SYNOPSIS
    Gets the type of repository for the provided path
.EXAMPLE
    Get-RepositoryType c:\path\to\repo
.PARAMETER path
    Retuns one of the following strings "svn", "git"
    or "git-svn"
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

$isSvnRepository = Test-SvnRepository $path
if($isSvnRepository -eq $true){
  return "svn"
}

$isGitRepository = Test-GitRepository $path
if($isGitRepository -eq $true){
  $isGitSvnRepository = Test-GitSvnRepository $path
  if($isGitSvnRepository -eq $true){
    return "git-svn"
  }
  return "git"
}
return "unknown"
}

Set-Alias update Update-Repository

Export-ModuleMember -Function Update-Repository
Export-ModuleMember -Alias update
