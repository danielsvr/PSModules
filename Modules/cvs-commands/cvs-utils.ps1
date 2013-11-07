# cvs common utility functions
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
    Write-Dbg "Test did't pass. Travers to parent."
    $pathToCheck = $pathToCheck.parent
  }
}

return $null

}
