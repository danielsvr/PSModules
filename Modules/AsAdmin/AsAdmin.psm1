function As-Admin {
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
Export-ModuleMember As-Admin