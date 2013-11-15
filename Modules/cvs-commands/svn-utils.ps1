# a group of functions that work with an svn repository.
#
# main functions:
#   Update-SvnRepository
#
# utility functions:
#   Get-SvnTool
#   Get-SvnRepositoryRootLocation
#

function Update-SvnRepository{
<#
.SYNOPSIS
    Updates the specified path using 'svn update' command
.EXAMPLE
    Update-SvnRepository c:\path\to\svn-repo
.PARAMETER path
    The path to be updated
#>
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $path
  )

  Write-Dbg "Updating svn repository $path"

  $svnTool = Get-SvnTool

  Write-Dbg "executing '$svnTool update $path'..."

  & $svnTool update $path
}

function Confirm-SvnChanges{
  param([string]$svnPath)

  Write-Dbg "Commiting changes to svn repository $path"

  $svnTool = Get-SvnTool

  Write-Dbg "executing '$vimTool ..."
  
  $message = Get-ConfirmationMessage $svnPath
  if($message){
    Write-Dbg "executing '$svnTool commit -m $message'..."
    & $svnTool commit $svnPath -m $message
  } else {
    Write-Host "No message was provided. commit aborted..."
  }
}

function Get-ConfirmationMessage{
  param([string]$svnPath)

  
}

function Get-SvnRepositoryRootLocation(){
  param(
    [Parameter(Mandatory=$true, Position=0)][string] $path
  )

  $s = $global:CvsSettings
  $svnHiddenDir = $s.SvnHiddenDirectory

  $svnPath = Get-RepositoryRootLocation $path { 
    # scriptblock param
    param($p) 
    $p = [System.IO.Path]::Combine($p, $svnHiddenDir)
    Write-Dbg "Testing existance of $svnHiddenDir"
    return Test-Path $p 
  }
  return $svnPath
}

function Get-SvnTool{
<#
.SYNOPSIS
  Tests if the git tool is installed
#>

  $s = $global:CvsSettings
  $toolPath = $s.SvnToolPath
  $svnTool = $s.SvnTool
  if(-not ($toolPath -eq $null)){
    $svnTool = "$toolPath\$svnTool"
  }

  Write-Dbg "Test if $svnTool is installed"
  if(Get-Command $svnTool -ErrorAction SilentlyContinue){
    Write-Dbg "$svnTool is installed"
    return $svnTool
  }

  Write-Dbg "$svnTool is not installed"
  throw "can't find $svnTool"
}
