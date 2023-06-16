
#$AllBU=$(az account list --all -o tsv --query "[].name")
AllBU="TOBEADDED"

for BU in $AllBU
do
    echo $BUname
    az account set -n $BU
    echo "#############################################################################################"
    echo "Get the status of AppServie Plan"
    echo "#############################################################################################"
    echo "AzureServiceType,AppServicePlan,Name,Status,Location,Pricing_Tier,isRedundant,isAutoScale,Instance_Count,MaxNumberWorker,ResourceGroup"
    az appservice plan list --output tsv --query "[].{ AppServicePlan:id, Name:name, Status:status, Location:location, Pricing_Tier:sku.tier, isRedundant:zoneRedundant, IsAutoScale:elasticScaleEnabled, Instance_Count:numberOfWorkers, MaxNumberWorker:maximumNumberOfWorkers, ResourceGroup:resourceGroup}" | sed 's/\t/,/g' | sed 's/^/AppServiePlan,/g'
    echo "#############################################################################################"
    echo "Get the status of Webapp & FunctionApp & LogicApp"
    echo "#############################################################################################"
    echo "AzureServiceType,AppName,Name,Location,Type,Status,AppServicePlan_ID,isRedundant"
    az webapp list --output tsv --query "[].{AppName:name, Location:location, Type:kind, Status:state, AppServicePlan:appServicePlanId, isRedundant:redundancyMode}" | sed 's/\t/,/g' | sed 's/^/WebApp,/g'
    az functionapp list --output tsv --query "[].{AppName:name, Location:location, Type:kind, Status:state, AppServicePlan:appServicePlanId, isRedundant:redundancyMode}"| sed 's/,/_/g' | sed 's/\t/,/g' | sed 's/^/FunctionApp,/g'
    az logicapp list --output tsv --query "[].{AppName:name, Location:location, Type:kind, Status:state, AppServicePlan:appServicePlanId, isRedundant:redundancyMode}" | sed 's/\t/,/g' | sed 's/^/LogicApp,/g'
done
