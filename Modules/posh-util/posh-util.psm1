# powershell utility functions
#

function Invoke-PreservingExitCode {
param(
  [scriptblock] $script,
  [array] $arguments
)
  $realLASTEXITCODE = $LASTEXITCODE
  $result = Invoke-Command -scriptblock $script -argumentlist $arguments
  $Global:LASTEXITCODE = $realLASTEXITCODE 
  return $result
}

Export-ModuleMember -Function Invoke-PreservingExitCode
