# a group of functions that work with a git repository
#
# main functions:
#   Update-GitRepository
#   Update-GitSvnRepository
#
# utility functions:
#   Test-GitSvnRepository
#   Get-GitRepositoryRootLocation
#   Get-GitTool
#


function Update-GitRepository{
<#
.SYNOPSIS
    Updates the specified path using 'git pull' command
.EXAMPLE
    Update-GitRepository c:\path\to\git-repo
.PARAMETER path
    The path to be updated
#>
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $path
  )

  Write-Dbg "Updating git repository $path"

  $gitTool = Get-GitTool

  Write-Dbg "executing '$gitTool pull'..."
  & $gitTool pull
}

function Update-GitSvnRepository{
<#
.SYNOPSIS
    Updates the specified path using 'git svn fetch' and
    'git svn rebase' command
.EXAMPLE
    Update-GitSvnRepository c:\path\to\git-svn-repo
.PARAMETER path
    The path to be updated
#>
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $path
  )

  Write-Dbg "Updating git-svn repository $path"

  $gitTool = Get-GitTool

  Write-Dbg "executing '$gitTool svn fetch'..."
  Write-Host "$gitTool svn fetch"
  & $gitTool svn fetch

  Write-Dbg "executing '$gitTool svn rebase'..."
  Write-Host "$gitTool svn rebase"
  & $gitTool svn rebase
}

function Test-GitSvnRepository{
<#
.SYNOPSIS
    Tests if the gitRootPath is a git-svn repository.
    This is done by looking into the config files and find
    any [svn-remote "someting"] defined
.EXAMPLE
    $isGitRepository = Test-GitSvnRepository c:\path\to\git-repo
.PARAMETER gitRootPath
    The git path to be tested as beeing a git-svn repository
#>
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $gitPath
  )

  $s = $global:CvsSettings

  $gitPath = [System.IO.Path]::Combine($gitPath, $s.GitHiddenDirectory)

  $svnRemotes = Get-Content $gitPath\config | sls '(\[svn\-remote)'

  if($svnRemotes) {
    Write-Dbg "$gitPath\config contains svn-remotes `n$svnRemotes"
    return $true
  }
  Write-Dbg "$gitPath\config contains no svn-remotes"
  return $false
}

function Get-GitTool{
  $s = $global:CvsSettings
  $toolPath = $s.GitToolPath
  $gitTool = $s.GitTool
  if(-not ($toolPath -eq $null)){
    $gitTool = "$toolPath\$gitTool"
  }

  Write-Dbg "Test if $gitTool is installed"
  if(Get-Command $gitTool -ErrorAction SilentlyContinue){
    Write-Dbg "$gitTool is installed"
    return $gitTool
  }

  Write-Dbg "$gitTool is not installed"
  throw "can't find $gitTool"
}

function Get-GitRepositoryRootLocation(){
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $path
  )

  $s = $global:CvsSettings
  $gitHiddenDir = $s.GitHiddenDirectory

  $gitPath = Get-RepositoryRootLocation $path { 
    # scriptblock param
    param($p) 
    # scriptblock body
    $p = [System.IO.Path]::Combine($p, $gitHiddenDir)
    Write-Dbg "Testing existance of $gitHiddenDir"
    return Test-Path $p 
  }
  return $gitPath
}

