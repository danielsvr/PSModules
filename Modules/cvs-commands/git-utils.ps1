# a groups of functions for updating an svn repository
#


function Update-GitRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

# code here...

}

function Update-GitSvnRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

# code here...

}

function Test-GitRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

$gitPath = Get-RepositoryRootLocation $path { param($p) return Test-Path $p }

# code here...
return $false
}

function Test-GitSvnRepository{
<#
.SYNOPSIS
.EXAMPLE
.EXAMPLE
.PARAMETER path
#>
param(
  [Parameter(Mandatory=$true, Position=0)][string] $path
)

# code here...
return $false
}
