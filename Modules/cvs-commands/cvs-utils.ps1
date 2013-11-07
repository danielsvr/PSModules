# cvs common utility functions
#

function Get-RepositoryRootLocation(){
param(
  [Parameter(Mandatory=$false)][string]$currentPath,
  [Parameter(Mandatory=$true)][scriptblock]$isRepositoryPredicate
)

$pathToCheck = $currentPath
while ($pathToCheck -ne $NULL) {
  $testPass = Invoke-Command -scriptblock $isRepositoryPredicate -argumentlist $pathToCheck
  if ($testPass) {
    return $pathToCheck
  } else {
    $pathToCheck = $pathToCheck.parent
  }
}

return $null

}
