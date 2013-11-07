# diagnostic utils for debugging cvs-commands
#



function Debug-Csv(){

param(
  [Parameter][string] $message
)

$s = $global:CvstSettings

if($s.Debug -eq $true){
  Write-Debug $message
}

}
