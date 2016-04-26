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

function New-SelfSigned-Certificate(){
param(
    [string]$CertDomain = "DevCert",
    [string]$RootCertName = 'DevRoot',
    [string]$RootCertPassword = 'Dev123',
    [string]$DevCertPassword = 'Dev123',
    [string]$WPath = "$profilepath\.data\.certs",
    [string]$MakecertPath = $null
)

    if((-not $MakecertPath) -or (-not (Test-Path $MakecertPath)))
    {
        $MakecertPath = "C:\Program Files (x86)\Windows Kits\10\bin\x64\"
    }
    if((-not $MakecertPath) -or (-not (Test-Path $MakecertPath)))
    {
        $MakecertPath = "C:\Program Files (x86)\Windows Kits\8.1\bin\x64\"
    }
    if((-not $MakecertPath) -or (-not (Test-Path $MakecertPath)))
    {
        $MakecertPath = "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\x64\"
    }

    $MakecertCommand = Get-Command "$MakecertPath\makecert.exe"
    $Pvk2PfxCommand = Get-Command "$MakecertPath\pvk2pfx.exe"

    if(-not (Test-Path $WPath)){
        mkdir $WPath
    }

    if($MakecertCommand -and $Pvk2PfxCommand) {

        $RootCertExists = $false;
        $InstalledRootCert = Get-ChildItem Cert:\LocalMachine\Root `
            | Where-Object { $_.Subject.Contains($RootCertName) } `
            | ForEach-Object { `
            $RootCertExists = $true `
        };
        # Write-Host "RootCertExists: $RootCertExists"

        $RootCerFile = "$WPath\$RootCertName.cer";
        $RootPvkFile = "$WPath\$RootCertName.pvk";
        $RootPfxFile = "$WPath\$RootCertName.pfx";

        $DevCerFile = "$WPath\$CertDomain.cer";
        $DevPvkFile = "$WPath\$CertDomain.pvk";
        $DevPfxFile = "$WPath\$CertDomain.pfx";

        if(-not $RootCertExists){

            if(Test-Path $RootCerFile) {
                Remove-Item $RootCerFile;
            }
            if(Test-Path $RootPvkFile) {
                Remove-Item $RootPvkFile;
            }
            if(Test-Path $RootPfxFile) {
                Remove-Item $RootPfxFile;
            }

            # Write-Host "$MakecertCommand -n 'CN=$RootCertName' -r -pe -a sha512 -len 4096 -cy authority -sv $RootPvkFile $RootCerFile;"
            & $MakecertCommand -sr LocalMachine -ss Root -n "CN=$RootCertName" -r -pe -a sha512 -len 4096 -cy authority -sv $RootPvkFile $RootCerFile;
            & $Pvk2PfxCommand -pvk $RootPvkFile -spc $RootCerFile -pfx $RootPfxFile -po $RootCertPassword;
        }

        & $MakecertCommand -n "CN=$CertDomain" -iv $RootPvkFile -ic $RootCerFile -pe -a sha512 -len 4096 -b 01/01/2014 -e 01/01/2022 -sky exchange -eku 1.3.6.1.5.5.7.3.1 -sv $DevPvkFile $DevCerFile
        & $Pvk2PfxCommand -pvk $DevPvkFile -spc $DevCerFile -pfx $DevPfxFile -po $DevCertPassword

        Write-Warning 'Please be advised, the pfx password is not the one set in the dialogs. It is the password set via $DevCertPassword parameter'
    }
}


Set-Alias newssc New-SelfSigned-Certificate

Export-ModuleMember -Function Set-AppCompatFlag
Export-ModuleMember -Function New-SelfSigned-Certificate

Export-ModuleMember -Alias newssc
