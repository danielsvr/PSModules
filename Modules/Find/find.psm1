function Find(){

param(
  [Parameter(Mandatory=$true, Position=0)][string] $Name,
  [string] $LookInto
)

if(-not $lookInto){
    $lookInto = Split-Path $PROFILE -Parent
}

get-childitem $lookInto -filter $name -recurse |
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

Export-ModuleMember -Function Find
