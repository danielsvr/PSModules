function Update-Profile(){
<#
.SYNOPSIS 
    An utility function for updating the powershell user profile folder
.EXAMPLE
    Update-Profile
#>
  Write-Verbose "Updating PSProfile for the current user $($env:USERNAME)"
  
  $vcsModule= Get-Module vcs-commands
  if($vcsModule -eq $null) {
    Write-Verbose "Vcs-commands module is not loaded, and trying to load it now."
    Import-Module vcs-commands -ErrorAction SilentlyContinue
    $vcsModule= Get-Module vcs-commands
    if($vcsModule -eq $null) {
      "Vcs-commands can't be loaded. Update aborted."
      return
    }    
  }

  Write-Verbose "Vcs-commands module is loaded"
  
  if(-not $global:VcsSettings.IsGitInstalled) {
    "Git is not installed. Update aborted."
    return
  } else {
    Write-Verbose "Git is installed"
  }

  $gitDir = $global:VcsSettings.GitHiddenDirectory
  $gitDir = "$profilepath\$gitDir"
  if(-not (Test-Path $gitDir)) {
    "Can't find $gitDir. Update aborted."
    return
  } else {
    Write-Verbose "$gitDir found."
  }

  $gitFetchFile = "$profilepath\.git\FETCH_HEAD"
  $lastGitFetch = Get-Date -Year 1900 -Month 1 -Day 1
  if(Test-Path $gitFetchFile) {
    Write-Verbose "$gitFetchFile found."
    $gitFetchFile = Get-Item $profilepath\.git\FETCH_HEAD
    $lastGitFetch = Get-Date ($gitFetchFile).LastWriteTime -Uformat %D
    Write-Verbose "Last git fetch was: $lastGitFetch"
  } else {
    Write-Verbose "$gitFetchFile is not found. An update will be forced."
  }
  
  $today = Get-Date -UFormat %D
  if(-not($lastGitFetch -eq $today)){
    Write-Verbose "Updating profile"
	  powershell -NoProfile -Command "cd $profilepath; git pull"
  } else {
    Write-Verbose "No update needed."
  }
}

function Restore-Profile {
<#
.SYNOPSIS 
    An utility function for re-run all the $PROFILEs in the current session.
.EXAMPLE
  Restore-Profile
#>
  @(
    $Profile.AllUsersAllHosts,
    $Profile.AllUsersCurrentHost,
    $Profile.CurrentUserAllHosts,
    $Profile.CurrentUserCurrentHost
  ) | % {
    if(Test-Path $_){
      Write-Verbose "Running $_"
      . $_
    }
  } 
}

function Restore-AllModules {
<#
.SYNOPSIS 
    An utility function for re-importing all the module loaded in the current session.
.EXAMPLE
  Restore-AllModules
#>
  Get-Module | ?{
    $_.ModuleBase.StartsWith($profilepath) 
  } | %{
    Remove-Module $_
    Import-Module $_.Name
  }

  Restore-Profile
}

