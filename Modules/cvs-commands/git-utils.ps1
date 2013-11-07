# a groups of functions for updating an svn repository
#


function Update-GitRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

Write-Dbg "Updating git repository $path"
# code here...

}

function Update-GitSvnRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

# code here...

}

function Test-GitRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

$s = $global:CvsSettings

$gitPath = Get-RepositoryRootLocation $path { 
  # scriptblock param
  param($p) 
  $p = [System.IO.Path]::Combine($p, $s.GitHiddenDirectory)
  return Test-Path $p 
}

if(-not ($gitPath -eq $null)){
  return $true
}

return $false
}

function Test-GitSvnRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

$s = $global:CvsSettings

$gitPath = [System.IO.Path]::Combine($path, $s.GitHiddenDirectory)

$svnRemotes = Get-Content $gitPath\config | sls '(\[svn\-remote)'
Write-Dbg "$gitPath\config conteins svn-remotes `n$svnRemotes"

if($svnRemotes) {
  return $true
}

return $false
}
