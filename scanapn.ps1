# Only one subscription 

$BU_name="XXXXX"
#Select-AzSubscription -SubscriptionName $BU_name -Tenant "XXXXX"

$apn_id=az appservice plan list --output tsv --query "[].id"

Write-Output "The redundant status of app service plan"

foreach ($apnid in $apn_id) {
    az appservice plan show --id $apnid --output tsv --query "{Name:name, Status:properties.status, Location:location, Pricing_Tier:sku.tier, AppServicePlan:id, Subscription:properties.subscription,  Type:kind, isRedundant:properties.zoneRedundant, IsAutoScale:properties.elasticScaleEnabled, Instance_Count:properties.numberOfWorkers, MaxNumberWorker:properties.maximumNumberOfWorkers, ResourceGroup:resourceGroup}"
    #az appservice plan show --id $apnid --output tsv --query "{Name:name, ResourceGroup:resourceGroup, isRedundant:properties.zoneRedundant, Subscription:properties.subscription}"
}

Write-Output "`n`n#############################################################################################"
Write-Output "Get the status of LogicApp, WepApp and FunctionApp"
Write-Output "#############################################################################################"
Get-AzWebApp | Select -Property Name, Kind, State, ServerFarmId



# Automate for every subscriptions
<#
$allsubscription=Get-AzSubscription
foreach ($currentsub in $allsubscription){
Select-AzSubscription -SubscriptionId $currentsub.Id


$apn_id=az appservice plan list --output tsv --query "[].id"

Write-Output "The redundant status of app service plan"

foreach ($apnid in $apn_id) {
    az appservice plan show --id $apnid --output tsv --query "{Name:name, ResourceGroup:resourceGroup, isRedundant:properties.zoneRedundant, Subscription:properties.subscription}"
}



}

#>
