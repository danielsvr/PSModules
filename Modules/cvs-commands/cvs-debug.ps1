# diagnostic utils for debugging cvs-commands
#



function Write-Dbg(){

$message = $args[0]

if($Global:CvsSettings.Debug -eq $true){
  $now = Get-Date -Format "yyyy-MM-dd HH:mm"
  Write-Host "$now DEBUG: $message" -Foreground Yellow
}

}
