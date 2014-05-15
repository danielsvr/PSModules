function Connect-RemoteDesktop {
<#
.SYNOPSIS 
    A utility function for connecting to remote desktop
.EXAMPLE
    Connect-RemoteDesktop 192.168.1.2
.PARAMETER machine
    The machine name or the ip address of the machine
#>
param(
  $machine
)
  Assert-Mstsc
  
  if($machine -eq $null) {
    $machine = Get-AvailableMachines | Get-UserSelection 
  }

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
  return $availableMachines
}

function Get-UserSelection {
param(
  [Parameter(Mandatory=$true, Position=0)]vailableOptions
)
}


Set-Alias rdc Connect-RemoteDesktop

Export-ModuleMember -Function Connect-RemoteDesktop
Export-ModuleMember -Alias rdc

