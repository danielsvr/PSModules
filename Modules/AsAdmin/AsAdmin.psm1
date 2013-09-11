function As-Admin {
<#
.SYNOPSIS 
    A shorter version of Start-Process -verb runas
.EXAMPLE
    As-Admin notepad path\to\file.txt
.PARAMETER args
    A list of parameters where the first one is the program to run.
#>
    if($args.Count -eq 0){
        "Please specify a program to run!"
        ""
        break
    }

    $prg = $args[0]
    $argList = New-Object 'System.Collections.Generic.List[System.Object]'
    
    for ($i=1; $i -lt $args.Count; $i++) {
        $argList.Add($args[$i])
    }
    if($argList.Count -eq 0) {
        start $prg -Verb runas
    } else {
        start $prg -ArgumentList $argList -Verb runas
    }
}
Set-Alias aa As-Admin
Set-Alias sudo As-Admin

Export-ModuleMember -Function As-Admin 
Export-ModuleMember -Alias aa
Export-ModuleMember -Alias sudo
