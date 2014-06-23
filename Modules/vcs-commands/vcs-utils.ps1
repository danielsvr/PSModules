# cvs common utility functions
#
# main functions:
#   Get-RepositoryRootLocation
#

function Get-RepositoryRootLocation(){
  param(
    [Parameter(Mandatory=$false)][string]$currentPath,
    [Parameter(Mandatory=$true)][scriptblock]$isRepositoryPredicate
  )

  $pathToCheck = $currentPath
  while ($pathToCheck -ne $NULL) {
    Write-Dbg "Testing $pathToCheck"
    $testPass = Invoke-Command -scriptblock $isRepositoryPredicate -argumentlist $pathToCheck
    if ($testPass) {
      Write-Dbg "Test pass"
      return $pathToCheck
    } else {
      Write-Dbg "Test did't pass."
      if($pathToCheck) {
        Write-Dbg "Travers to parent."
        $pathToCheck = Split-Path $pathToCheck -Parent
      } else {
        Write-Dbg "Stop travering."
        $pathToCheck = $null
      }
    }
  }

  return $null
}
