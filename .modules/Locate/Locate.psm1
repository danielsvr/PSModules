#function Update-Db(){

#[Reflection.Assembly]::LoadWithPartialName("System.IO")
#[Reflection.Assembly]::LoadWithPartialName("System.IO.IsolatedStorage")
#
#$file_noshare = [System.IO.FileShare]::None
#$file_write = [System.IO.FileAccess]::Write
#$file_open = [System.IO.FileMode]::Create
#
#$db_temp_filename = [System.IO.Path]::GetTempFileName()
#
#$userIsoStorage = [System.IO.IsolatedStorage.IsolatedStorageFile]::GetUserStoreForAssembly()
#$userIsoStorage.CreateDirectory("PowerShell_LocateDb")
#
#$db_temp = New-Object System.IO.IsolatedStorage.IsolatedStorageFileStream($db_temp_filename, $file_open, $file_write, $file_noshare, $userIsoStorage)

Get-PSProvider -PSProvider FileSystem | %{ 
    $_.Drives | %{
        Get-ChildItem $_.Root -Recurse -File | % {
            New-Object PSObject -Property @{ Name = $_.Name; Location = $_.DirectoryName }
        }
    }
}


#$db = New-Object System.IO.IsolatedStorage.IsolatedStorageFileStream("locate.db", [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None, $userIsoStorage)


#}

#Set-Alias updatedb Update-Db