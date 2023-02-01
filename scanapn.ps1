
$AllBU=$(az account list --all -o tsv --query "[].name")

foreach ($BUname in $AllBU){

    Write-Output "`n`n#############################################################################################"
    Write-Output $BUname
    Write-Output "#############################################################################################"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of AppServie Plan"
    Write-Output "#############################################################################################"
    az appservice plan list --output tsv --query "[].{ AppServicePlan:id, Name:name, Status:status, Location:location, Pricing_Tier:sku.tier, isRedundant:zoneRedundant, IsAutoScale:elasticScaleEnabled, Instance_Count:numberOfWorkers, MaxNumberWorker:maximumNumberOfWorkers, ResourceGroup:resourceGroup}"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of Webapp"
    Write-Output "#############################################################################################"
    az webapp list --output tsv --query "[].{AppName:name, Location:location, Type:kind, Status:state, AppServicePlan:appServicePlanId}"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of FunctionApp"
    Write-Output "#############################################################################################"
    az functionapp list --output tsv --query "[].{AppName:name, Location:location, Type:kind, Status:state, AppServicePlan:appServicePlanId}"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of LogicApp"
    Write-Output "#############################################################################################"
    az logicapp list --output tsv --query "[].{AppName:name, Location:location, Type:kind, Status:state, AppServicePlan:appServicePlanId}"

}
