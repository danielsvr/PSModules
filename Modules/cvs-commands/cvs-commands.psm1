# a groups of functions that ease the usage of svn, 
# git or git-svn type repositories
#

# usings
. .\cvs-utils.ps1
. .\svn-utils.ps1
. .\git-utils.ps1


$global:CvsSettings = New-Object PSObject -Property @{
  Debug              = $false,
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
  $path = "."
}

$repoType = Get-RepositoryType $path

Write-Debug "$repoType repository discoverd."
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
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

($isSvnRepository = Test-SvnRepository $path) | Out-Null
if($isSvnRepository -eq $true)
  return "svn"

($isGitRepository = Test-GitRepository $path) | Out-Null
if($isGitRepository -eq $true){
  ($isGitSvnRepository = Test-GitSvnRepository $path) | Out-Null
  if($isGitSvnRepository -eq $true)
    return "git-svn"
  return "git"
}
return "unknown"
}

Set-Alias update Update-Repository

Export-ModuleMember -Function Update-Repository
Export-ModuleMember -Alias update
