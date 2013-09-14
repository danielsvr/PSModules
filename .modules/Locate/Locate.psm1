function Update-Db(){

$file_noshare = [System.IO.FileShare]::None
$file_write = [System.IO.FileAccess]::Write
$file_open = [System.IO.FileMode]::Create

$db_temp_filename = $env:ALLUSERSPROFILE + "\locate\locations.tmp"
#$env:ALLUSERSPROFILE

New-Item -ItemType directory $env:ALLUSERSPROFILE\locate -Force | Out-Null
$db_temp = New-Object System.IO.FileStream(
            $db_temp_filename, $file_open, $file_write, $file_noshare)

$hash = New-Object System.Collections.Hashtable
$formatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter

Get-PSProvider -PSProvider FileSystem | % { 
    $_.Drives | % {
        Get-ChildItem $_.Root -Recurse | % {
            $parentName = $_.DirectoryName
            $isDirectory = $_.PSIsContainer;
            if($_.PSIsContainer -eq $true){
                $parentName = $_.Parent.FullName
                $isDirectory = $true;
            }

            $entry = New-Object PSObject -Property @{ 
                Location = $parentName; 
                IsDirectory = $isDirectory
            }
            $list = $hash[$_.Name]
            if($list -eq $null){
                $list = New-Object System.Collections.ArrayList
                $hash[$_.Name] = $list
            }
            
            $list.Add($entry) | Out-Null
        }
    }
}

$formatter.Serialize($db_temp, $hash);
$db_temp.Flush($true)
$db_temp.Close()
$db_temp.Dispose()

}

function locate([string]$name){

$name = "msbuild.exe"
$file_noshare = [System.IO.FileShare]::Read
$file_write = [System.IO.FileAccess]::Read
$file_open = [System.IO.FileMode]::Open

$db_temp_filename = $env:ALLUSERSPROFILE + "\locate\locations.tmp"


$db_temp = New-Object System.IO.FileStream(
            $db_temp_filename, $file_open, $file_write, $file_noshare)

$hash = New-Object System.Collections.Hashtable
$formatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter

$hash = $formatter.Deserialize($db_temp);
$db_temp.Close()
$db_temp.Dispose()

$hash[$name]

}

#Set-Alias updatedb Update-Db