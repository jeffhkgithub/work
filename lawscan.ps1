# This script is used to scan if the diagnostics setting is enabled for each Azure resources 


#$allsubscription=Get-AzSubscription
#foreach ($currentsub in $allsubscription){
#Select-AzSubscription -SubscriptionId $currentsub.Id

$resources = Get-AzResource
#$resources = Get-AzResource | where ResourceType -Match "Microsoft.compute"

Write-Output "These resources doesn't have diagnostic setting"

foreach ($azResource in $resources) {

$resourceId = $azResource.ResourceId 

$azDiagSettings = Get-AzDiagnosticSetting -ResourceId $resourceId -ErrorAction SilentlyContinue -ErrorVariable errormsg
if ($errormsg -ne $null) {
    $errormsg=$null
    }
elseif (!$azDiagSettings) {
    Write-Output "ResourceType: $($azResource.ResourceType) | ResourceName: $($azResource.Name) | ResourceGroup: $($azResource.ResourceGroupName) | SubscriptionName: $($currentsub.Name)"
}    



}
#}
