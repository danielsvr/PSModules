Function Get-SolutionProjects(
  [Parameter(Mandatory = $true)][string]$Solution,
  [Parameter(Mandatory = $false)][switch]$NamesOnly
) {

  $slnDirectory = Split-Path -Path $Solution -Parent
  $slnContent = Get-Content $Solution 
  $linesContainingProjectNames = $slnContent | Select-String 'Project\('
  $projects = $linesContainingProjectNames | ForEach-Object { 
    $splited = $_ -Split '[,=]'
    $cleaned = $splited | ForEach-Object { $_.Trim('[ "{}]') }
    return @{
      Name = $cleaned[1];
      RelativeSlnPath = $cleaned[2];
      ExpectedFullPath = "$slnDirectory\$($cleaned[2])";
    }
  }

  if($NamesOnly.IsPresent) {
    return $projects | ForEach-Object { $_.Name }
  } else {
    return $projects | Where-Object {
      $_.ExpectedFullPath.EndsWith("proj")
    } | ForEach-Object { 
      if(-not (Test-Path $_.ExpectedFullPath)) {
        Write-Error "ProjectNotFound: $($_.ExpectedFullPath)"
      } 
      return [PSCustomObject]@{
        ProjectExists = Test-Path $_.ExpectedFullPath;
        ProjectName = $_.Name;
        File = Get-Item $_.ExpectedFullPath -ErrorAction SilentlyContinue;
      } 
    } | Format-Table -AutoSize
  }
}

Function Get-ProjectsNotIncludedInSolution(
  [Parameter(Mandatory = $true)][string]$Solution,
  [Parameter(Mandatory = $false)][string]$Path
) {

  if(-not $Path){
    $Path = Split-Path -Path $Solution -Parent
  }
  $projectNames = Get-SolutionProjects -Solution $Solution -NamesOnly
  return Get-ChildItem -Recurse -Path $Path -Filter "*.*proj" | Where-Object {
    -not ($projectNames -contains $_.BaseName)
  }
}

Set-Alias slnls Get-SolutionProjects
Set-Alias not-slnls Get-ProjectsNotIncludedInSolution

Export-ModuleMember `
    -Alias @(
        'slnls',
        'not-slnls') `
    -Function @(
        'Get-SolutionProjects',
        'Get-ProjectsNotIncludedInSolution')