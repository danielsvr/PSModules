function Connect-RemoteDesktop {
<#
.SYNOPSIS 
    A utility function for connecting to remote desktop
.EXAMPLE
    Connect-RemoteDesktop 192.168.1.2
.PARAMETER machine
    The machine name or the ip address of the machine
.PARAMETER as
    The alias to be used in case that machine name is not already saved
#>

# this seems to be important when you need the common parametes to work with your modules
[CmdletBinding()]


param(
  $machine,
  $as
)
  Assert-Mstsc
  Write-Verbose "machine is $machine and alias is $as"


  $alias = $machine
  if(-not ($as -eq $null)) {
    Write-Verbose "as is not null"
    Write-Verbose "setting alias to $as"
    $alias = $as
  }

  
  if(-not ($alias -eq $null)) {
    Write-Verbose "Get machine by alias '$alias'"
    $machines = Get-AvailableMachines
    $foundMachine = ($machines | ?{ $_.Alias -eq $alias } | Select -First 1).ID

    if(-not $foundMachine) { 
      Write-Verbose "No machine found by alias $alias"
    }

    if($foundMachine) {
      Write-Host "Found machine $foundMachine for alias $alias"
      if((-not ($alias -eq $machine)) -and (-not ($machine -eq $foundMachine))) {
        Write-Host "Conflict on alias $alias (already used for $foundMachine)"
        return
      }
      $machine = $foundMachine
    }
  }

  if($machine -eq $null) {
    Write-Verbose "I: Getting available machines from history"
    $machines = Get-AvailableMachines
    $machine = Get-UserSelection $machines
  }

  if($machine -eq $null) {    
    Write-Verbose "No machine was selected!"
    Write-Verbose "Running mstsc"
    mstsc
    return
  }

  Backup-Input $machine $alias

  Write-Verbose "Running mstsc /v:$machine"
  mstsc /v:$machine
}

function Assert-Mstsc {
  $mstsc = $null
  ($mstsc = Get-Command mstsc -ErrorAction Continue) | Out-Null
  
  if ($mstsc -eq $null) {
    $nomstscerror = New-Object `
      'System.InvalidOperationException' `
      -ArgumentList 'mstsc not found'

    throw $nomstscerror
  }
}

function Get-AvailableMachines {
  [array] $availableMachines = @()

  if (!(Get-Command Get-IniContent -TotalCount 1 -ErrorAction SilentlyContinue)) {
    Write-Verbose "W: Get-IniContent not found. Connections history will not be available"
    return $availableMachines
  }
  
  $filepath = "$profilepath\.data\Connect-RemoteDesktop.ini"
  $fileExists = Test-Path $filepath
  
  if(-not $fileExists) {
    Write-Verbose "I: '$filepath' does not exists"
    return $availableMachines
  }

  $content = Get-IniContent $filepath
  
  $machines = $content["machines"]
  Write-Verbose "Machines found"

  if($machines.Count -gt 0) {
    $machines.Keys | %{ 
        $key = $_
        $val = $machines["$_"]
        Write-Verbose "$key = $val" 
    }
  }

  Write-Verbose "=============="
  $aliases = $content["aliases"]
  Write-Verbose "Aliases found"
  
  if($aliases.Count -gt 0) {  
    $aliases.Keys | %{ 
        $key = $_
        $val = $aliases["$_"]
        Write-Verbose "$key = $val" 
    }
  }

  Write-Verbose "=============="
  if($machines.Count -gt 0) {
    $machines.Keys | % {
      $machine = New-Object PSObject
      $machine | Add-Member NoteProperty -Name ID -Value $_
      $machine | Add-Member NoteProperty -Name IP -Value $machines[$_]
      
      if (($aliases.Count -gt 0) -and ($aliases.ContainsKey($_))) {
        $machine | Add-Member NoteProperty -Name Alias -Value $aliases[$_]
      }
      
      $availableMachines += $machine
    }
  }
  return $availableMachines
}

function Get-UserSelection {
param(
  [array]$availableOptions
)
  $zero = 0

  if($availableOptions.Count -le $zero) {
    return $null
  }

  Write-Host "Connections History:"
  $i = 0

  Write-Verbose "Available options count: $($availableOptions.Count)"

  $availableOptions | %{
    # Write-Host $_
    $alias = $_.Alias
    if(-not ($alias -eq $null)) {
      $alias = "($alias)"
    } else {
      $alias = " "
    }
    if($i -eq $null) {
      Write-Verbose '$i is null'
    }
    if($_.ID -eq $null) {
      Write-Verbose '$_.ID is null'
    }
    if($_.IP -eq $null) {
      Write-Verbose '$_.IP is null'
    }
    if($alias -eq $null) {
      Write-Verbose '$alias is null'
    }

    $i = $i + 1
    Write-Host $("{0,3} -> {1} - {2} {3}" -f $i, $_.ID, $_.IP, $alias)
  }
  
  $selection = Read-Host "Select"

  $i = $selection - 1
  if(($availableOptions.Count -gt $i) -and ($i -ge 0)) {    
    $selected = $availableOptions[$i]
  } else {
    $selected = ($availableOptions | ? { `
                    $_.IP -eq $selection -or `
                    $_.Alias -eq $selection -or `
                    $_.ID -eq $selection
                } | Select -First 1)
  }
  return $selected.ID
}

function Backup-Input{
param (
  $machine,
  $alias
)
  Write-Verbose "Backing up '$machine ($alias)' in the ini file"
  if (!((Get-Command Out-IniFile -TotalCount 1 -ErrorAction SilentlyContinue) `
      -and (Get-Command Get-IniContent -TotalCount 1 -ErrorAction SilentlyContinue))) {
    Write-Verbose "W: Out-IniFile or Get-IniContent not found. Connections history will not be available"
    return
  }

  $dataDirectory = "$profilepath\.data"
  $dataDirectoryExists = Test-Path $dataDirectory
  
  if(-not $dataDirectoryExists) {    
    Write-Verbose "I: '$dataDirectory' does not exists"
    md $dataDirectory
  }

  $filepath = "$profilepath\.data\Connect-RemoteDesktop.ini"
  $fileExists = Test-Path $filepath
  
  if(-not $fileExists) {    
    Write-Verbose "I: '$filepath' does not exists"
@"
[machines]

[aliases]

"@ | Out-File $filepath -Encoding ASCII
  }

  $content = Get-IniContent $filepath

  $existingKey = $content["machines"].Keys | ? { $_ -eq $machine} | select -First 1
  
  if(-not ($existingKey -eq $null)) {
    Write-Verbose "I: key exists $machine"
    return
  }

  $ipPattern = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
  $entry = @{}
  switch -regex ($machine) {
    $ipPattern {
      $entry = @{ "$machine"="$machine" }
    }
    default {
      $ip = ping $machine -4 -a -n 1 |`
        sls -Pattern $ipPattern |`
        select Matches -First 1 |`
        %{ $_.Matches } | %{ $_.Value }

      $entry = @{ "$machine"="$ip" }
    }
  }

  $content["machines"]["$machine"] = $entry["$machine"]
  if(-not ($alias -eq $null)) {
    $content["aliases"]["$machine"] = $alias
  }

  rm $filepath -Force
  if(-not (Test-Path $filepath)) {
    Out-IniFile -InputObject $content -File $filepath -Encoding ASCII
  }
}


Set-Alias rdc Connect-RemoteDesktop

Export-ModuleMember -Function Connect-RemoteDesktop
Export-ModuleMember -Alias rdc

