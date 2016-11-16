function Chack-Vagrant(){
param()
# this checks is vagrant is installed
}

function Clear-VagrantBoxes(){
param()
  vagrant box list | `
    %{ $_.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) } |`
    ?{ -not $_.StartsWith('(') -and -not $_.EndsWith(')') } |` 
    %{ vagrant box remove $_ --all }
}


Export-ModuleMember -Function Clear-VagrantBoxes
