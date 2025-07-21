
      # Read pipeline variables
      $environment = "$(Environment)"
      $resourceGroup = "$(ResourceGroup)"
      $vmName = "$(VmName)"

      # Set artifact path
      $templateFile = "$(System.DefaultWorkingDirectory)/_PercyJackson/infrastructure/vm-deployment/azuredeploy.json"
      $parameterFile = "$(System.DefaultWorkingDirectory)/_PercyJackson/infrastructure/vm-deployment\azuredeploy.parameters.json"


      # Show context
      Write-Output "🔍 Environment: $environment"
      Write-Output "🔍 Resource Group: $resourceGroup"
      Write-Output "🖥️ VM Name: $vmName"
      Write-Output "📄 Template: $templateFile"
      Write-Output "📄 Parameters: $parameterFile"

      # Check if the resource group exists
      $rg = Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue
      if (-not $rg) {
          Write-Output "❌ Resource group '$resourceGroup' does not exist."
          exit 1
      }

      # Override vmName in the parameter file
      $parameters = Get-Content $parameterFile | ConvertFrom-Json
      $parameters.parameters.vmName.value = $vmName
      $parameters | ConvertTo-Json -Depth 10 | Out-File "overridden-parameters.json" -Encoding utf8

      # Run deployment
      Write-Output "🚀 Deploying ARM template..."
      New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroup `
        -TemplateFile $templateFile `
        -TemplateParameterFile "overridden-parameters.json" `
        -Verbose


if ($?) {
    Write-Output "✅ Deployment succeeded."
} else {
    Write-Output "❌ Deployment failed."
    Write-Output "Last error: $($error[0])"
    exit 1
}
