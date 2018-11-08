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
        $MakecertPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64"
    }
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

function Export-NewSelfSignedCertificate(){
param(
    [string]$CertDomain = "localhost",
    [string]$CertName = "DevCert",
    [string]$RootCertName = 'DevRoot',
    [string]$RootCertPassword = 'Dev123',
    [string]$DevCertPassword = 'Dev123',
    [string]$WPath = "$profilepath\.data\.certs"
)

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

if(-not $RootCertExists) {

	if(Test-Path $RootCerFile) {
		Remove-Item $RootCerFile;
	}
	if(Test-Path $RootPvkFile) {
		Remove-Item $RootPvkFile;
	}
	if(Test-Path $RootPfxFile) {
		Remove-Item $RootPfxFile;
	}

	# Note: the current defaults for New-SelfSignedCertificate are 2048 bit RSA keys with SHA256 -- if they change them, it'll be to stronger options, so let's accept the defaults for now
	$rootExtension = [System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]::new($true, $true, 0, $true)
	$root = New-SelfSignedCertificate `
		-Extension $rootExtension `
		-Subject "CN=$RootCertName" `
		-DnsName "$RootCertName" `
		-NotAfter (Get-Date).AddYears(2) `
		-KeyUsage "CertSign" `
		-CertStoreLocation "Cert:\LocalMachine\My" 
		#-KeyExportPolicy "NonExportable" `
	 
	$cer = New-SelfSignedCertificate `
		-Signer $root `
		-Subject "CN=$CertName" `
		-DnsName "$CertDomain" `
		-NotAfter ((Get-Date).AddYears(1))

	Move-Item "Cert:\LocalMachine\My\$($root.Thumbprint)" -Destination "Cert:\LocalMachine\Root"
	
	Export-Certificate -FilePath $RootCerFile -Cert "Cert:\LocalMachine\Root\$($root.Thumbprint)" `
	 -Type CERT
	 
	Export-PfxCertificate -FilePath $RootPfxFile -Cert "Cert:\LocalMachine\Root\$($root.Thumbprint)" `
	 -Password $(ConvertTo-SecureString -String "$RootCertPassword" -AsPlainText -Force)

	 Export-Certificate -FilePath $DevCerFile -Cert "Cert:\LocalMachine\My\$($cer.Thumbprint)" `
	 -Type CERT
	 
	Export-PfxCertificate -FilePath $DevPfxFile -Cert "Cert:\LocalMachine\My\$($cer.Thumbprint)" `
	 -Password $(ConvertTo-SecureString -String "$DevCertPassword" -AsPlainText -Force)
} else {

	if(-not $root) {
		$rootThumbprint = Get-ChildItem Cert:\LocalMachine\Root `
			| Where-Object { $_.Subject.Contains($RootCertName) } `
			| Foreach-Object { return $_.Thumbprint } `
			| Select-Object -First 1

		$root = Get-Item "Cert:\LocalMachine\Root\$rootThumbprint"

		if(-not $root) {
			Write-Error "No Root"
		}
	}

	Move-Item "Cert:\LocalMachine\Root\$rootThumbprint" -Destination "Cert:\LocalMachine\My"

	$cer = New-SelfSignedCertificate `
		-Signer $root `
		-Subject "CN=$CertName" `
		-DnsName "$CertDomain" `
		-NotAfter ((Get-Date).AddYears(1))

	Export-Certificate -FilePath $DevCerFile -Cert "Cert:\LocalMachine\My\$($cer.Thumbprint)" `
	 -Type CERT
	 
	Export-PfxCertificate -FilePath $DevPfxFile -Cert "Cert:\LocalMachine\My\$($cer.Thumbprint)" `
	 -Password $(ConvertTo-SecureString -String "$DevCertPassword" -AsPlainText -Force)
	 
	Move-Item "Cert:\LocalMachine\My\$rootThumbprint" -Destination "Cert:\LocalMachine\Root"
}
}

function Edit-Hosts {
   Start-AsAdmin powershell -Command { `
    Set-ItemProperty "${env:SystemRoot}\System32\drivers\etc\hosts" IsReadOnly $false;`
    vim "${env:SystemRoot}\System32\drivers\etc\hosts";`
    Set-ItemProperty "${env:SystemRoot}\System32\drivers\etc\hosts" IsReadOnly $true;`
  }
}

Add-Type -TypeDefinition @"
   public enum FileEncodingType
   {
      ascii,
      utf8,
      unicode
   }
"@

function Convert-FileEncoding {
param (
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true)]
    [string]$FileName,
    [Parameter(Mandatory=$false)]
    [FileEncodingType]$Encoding=[FileEncodingType]::ASCII,
    [Parameter(Mandatory=$false)]
    [switch]$NoBackup=$false
)
process {
        if(-not (Test-Path $FileName)) {
            Write-Error "File does not exist"
            return
        }   

        if($FileName.Contains(".bck")) {
            Write-Debug "File $FileName is a backup file. SKIP"
            return
        }

        $Destination = $FileName
        Copy-Item -Path $FileName -Destination "$($FileName).bck"
        $FileName = "$($FileName).bck"

        Write-Debug "Copied $Destination to $FileName`nChanging Encoding to $Encoding"

        Get-Content $FileName | Out-File -FilePath $Destination -Encoding $Encoding

        if($NoBackup.IsPresent) {
            Write-Debug "NoBackup parameter is set. Backup file not kept"
            Remove-Item -Force $FileName
            Write-Debug "Backup file $FileName is removed."
        }
    }
}

Set-Alias newssc New-SelfSigned-Certificate
Set-Alias changefiletype Convert-FileEncoding

Export-ModuleMember -Function Edit-Hosts
Export-ModuleMember -Function Convert-FileEncoding
Export-ModuleMember -Function Set-AppCompatFlag
Export-ModuleMember -Function New-SelfSigned-Certificate
Export-ModuleMember -Function Export-NewSelfSignedCertificate

Export-ModuleMember -Alias newssc
Export-ModuleMember -Alias changefiletype
