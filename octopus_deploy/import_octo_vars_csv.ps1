$ApiKey = "API-KEY"
Add-Type -Path 'C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll'
$endpoint = New-Object Octopus.Client.OctopusServerEndpoint("http://localhost",$ApiKey)
$repository = New-Object Octopus.Client.OctopusRepository($endpoint)
$project = $repository.Projects.FindByName('PROJECT_NAME')
$variableset = $repository.VariableSets.Get('variableset-Projects-PROJECT_ID')
$variables = $repository.VariableSets.Get($variableset.VariableSetId)

Import-CSV 'D:\testConfig.csv' -Header Key,Value,Environment | Foreach-Object {
  $environment = $_.Environment
  $variableName = $_.Key
  $variableValue = $_.Value

  Write-Host $environment
  Write-Host $variableName
  Write-Host $variableValue

  $project = $repository.Projects.FindByName('PROJECT_NAME')
  $variableset = $repository.VariableSets.Get('variableset-Projects-PROJECT_ID')
  $variables = $repository.VariableSets.Get($variableset.VariableSetId)

  $myNewVariable = new-object Octopus.Client.Model.VariableResource
  $myNewVariable.Name = $variableName
  $myNewVariable.Value = $variableValue
  #$myNewVariable.Scope.Add([Octopus.platform.Model.Scopefield]::Environment, (New-Object Octopus.Platform.Model.ScopeValue("$environment")))
  #$myNewVariable.Scope.Add([Octopus.platform.Model.Scopefield]::Environment, (New-Object Octopus.Platform.Model.ScopeValue("Environments-ENVIRONMENT_ID)))

  $variableset.Variables.Add($myNewVariable)
  $repository.VariableSets.Modify($variableset)
}
