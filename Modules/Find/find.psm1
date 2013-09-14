function Find-Name(){

param(
  [Parameter(Mandatory=$true, Position=0)][string] $Name,
  [string] $LookInto
)

if(-not $LookInto){
    $LookInto = $env:USERPROFILE
}

get-childitem $LookInto -filter $name -recurse |
   %{ 
        $parent = $_.Parent
        if($parent -eq $null){
            $parent = $_.Directory
        }
        $name = $_.Name
        if($_.Attributes -eq [System.IO.FileAttributes]::Directory){
            $name = "[" + $name + "]"
        }
        new-object psobject -property  @{ Name = $name ; Path = $parent.FullName } 
    }
}
Set-Alias find Find-Name

Export-ModuleMember -Function Find-Name
Export-ModuleMember -Alias find
