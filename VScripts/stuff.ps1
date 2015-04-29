
C:\windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command { start "C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe" -ArgumentList ("C:\Users\IBM_ADMIN\OneDriveHome\OneDrive\lockInfo\MyKees.kdbx", "-pw:$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR((Get-Content -Path "$env:USERPROFILE\.kpass" | ConvertTo-SecureString))))") }

ConvertTo-SecureString '<HERE>' -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$env:USERPROFILE\.kpass"

 