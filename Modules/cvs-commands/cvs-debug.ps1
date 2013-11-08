# diagnostic utils for debugging cvs-commands
#
# main functions:
#   Write-Dbg
#



function Write-Dbg(){
  $message = $args[0]

  if($Global:CvsSettings.Debug -eq $true){
    $now = Get-Date -Format "HH:mm:ss.fff"
    Write-Host "$now DEBUG: $message" -Foreground Yellow
  }
}
