function Set-AppCompatFlag {
<# 
       .SYNOPSIS 
        Sets the Compatibility flags for an application. 
       
       .EXAMPLE 
        Set-AppCompatFlag.ps1 -Path 'c:\windows\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe'
        This sets the RUNASADMIN flag for the ISE
        
       .EXAMPLE 
        Set-AppCompatFlag.ps1 -Path 'c:\windows\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe' -ComputerName RemoteServer01 
        This sets the RUNASADMIN flag for the ISE on RemoteServer01.
        
       .PARAMETER  Path
        The full path to the executable to flag for compatibility.
       
       .PARAMETER  ComputerName
        Computer to run the command against.  If this is a remote computer, the Remote Registry service needs to be running.  This defaults to the local machine.
       
       .PARAMETER  Scope
        The scope to set the compatibility flag at.  This can be the CurrentUser or the LocalMachine level.  The default is CurrentUser.
       
       .PARAMETER  Flag
        The compatibility flag to set.  Currently supports:
            "RUNASADMIN", 
            "WINSRV03SP1", 
            "WINSRV08SP1",
            "WINXPSP2", 
            "WINXPSP3", 
            "DISABLETHEMES", 
            "640X480", 
            "HIGHDPIAWARE", 
            "256COLOR",
            "DISABLEDWM".  
        The default is RUNASADMIN.

       .NOTES 
        NAME: Set-AppCompatFlag
        AUTHOR: Steven Murawski 
        LASTEDIT: February 07, 2011 5:27:44 PM
        KEYWORDS: 
         
        #Requires -Version 2.0 
#> 
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)] 
        [alias('FullName','FullPath')]
        [string] 
        $Path,
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)] 
        [string[]] 
        $ComputerName,
        [Parameter(Position=2)]
        [string]
        [ValidateSet("CurrentUser", "LocalMachine")] 
        $Scope = "CurrentUser",
        [Parameter(Position=3)]
        [string]
        [ValidateSet("RUNASADMIN", 
            "WINSRV03SP1", 
            "WINSRV08SP1",
            "WINXPSP2", 
            "WINXPSP3", 
            "DISABLETHEMES", 
            "640X480", 
            "HIGHDPIAWARE", 
            "256COLOR",
            "DISABLEDWM")] 
        $Flag = "RUNASADMIN"
    )
    
    process
    {
        if (($ComputerName -eq $null) -or ($ComputerName.count -lt 1))
        {
            $ComputerName = @($env:COMPUTERNAME)
        }
        
        foreach ($Computer in $ComputerName)
        {
            try
            {
                Write-Debug "Opening Remote Registry"
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Scope, $Computer)   
                                   
                Write-Debug 'Reading SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Layers'   
                $keys = $reg.OpenSubKey('SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Layers', $true)
                
                
                Write-Debug "Checking to see if $Path already has AppCompatFlags"
                
                $NotFlagged = $true
                $NotSet = $true
                
                if ($keys.GetValueNames() -contains $Path)
                {
                    Write-Debug "Checking to see if $Path already has $Flag set"
                    if ($keys.GetValue($Path) -like "*$Flag*")
                    {
                        $NotFlagged = $false
                        Write-Debug "Found Application and it was already flagged - $Flag"
                    }
                    else
                    {
                        $CurrentValue = $keys.GetValue($Path)
                        Write-Debug "Adding $Flag for $path  to $Current on $Computer"
                        $NewFlag = "$CurrentValue $Flag"
                        
                        Write-Debug "Setting $Flag for $path on $Computer"
                        $Keys.SetValue($path, $NewFlag)
                        Write-Verbose "Set $NewFlag for $path on $Computer"
                        $NotSet = $false
                    }
                }
                
                if ($NotFlagged -and $NotSet)
                {
                    Write-Debug "Setting $Flag for $path on $Computer"
                    $keys.SetValue("$path","$flag")
                    
                    Write-Verbose "Set $Flag for $path on $Computer"
                }
                else
                {
                    Write-Debug "Did not set $Flag for $Path on $Computer.  Flag already existed."
                    Write-Verbose "Did not set $Flag for $Path on $Computer.  Flag already existed."
                }
            }
            catch [Exception]
            {
                Write-Debug "Failed to connect to the remote registery or error reading the remote key."
                Write-Error $_.Exception
            }
        }
    }
}

function proc(){
#param(
#  $action
#)
    
  gwmi Win32_Process 
  #-Filter "name = 'java.exe'" | select CommandLine,ProcessId | Format-List
}

Export-ModuleMember -Function Set-AppCompatFlag