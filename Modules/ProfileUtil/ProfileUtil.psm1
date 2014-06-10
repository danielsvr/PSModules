function Update-Profile(){
<#
.SYNOPSIS 
    An utility function for updating the powershell user profile folder
.EXAMPLE
    Update-Profile
#>
  $cvsModule= Get-Module cvs-commands
  if($cvsModule -eq $null) {
    Import-Module cvs-commands -ErrorAction SilentlyContinue
    $cvsModule= Get-Module cvs-commands
    if($cvsModule -eq $null) {
      return
    }
  }

  if(-not $global:CvsSettings.IsGitInstalled) {
    return
  }

  $profilepath = Split-Path $PROFILE -parent

  $gitFetchFile = "$profilepath\.git\FETCH_HEAD"
  if(-not (Test-Path $gitFetchFile)) {
    return
  }
  $gitFetchFile = Get-Item $profilepath\.git\FETCH_HEAD
  $lastGitFetch = Get-Date ($gitFetchFile).LastWriteTime -Uformat %D
  $today = Get-Date -UFormat %D
  if(-not($lastGitFetch -eq $today)){
	  powershell -NoProfile -Command "cd $profilepath; git pull"
  }
}

function Restore-Profile {
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
  Get-Module | ?{ 
    $_.ModuleBase.StartsWith($profilepath) 
  } | %{
    Remove-Module $_
    Import-Module $_.Name
  }
  Restore-Profile
}

Set-Alias rc                  Restore-AllModules
Set-Alias rstcon              Restore-AllModules

Export-ModuleMember -Function Restore-AllModules
Export-ModuleMember -Function Restore-Profile
Export-ModuleMember -Function Update-Profile
Export-ModuleMember -Alias    rc
Export-ModuleMember -Alias    rstcon

