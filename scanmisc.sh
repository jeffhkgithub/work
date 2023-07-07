# This script is to scan Zone Redundancy
# Azure API Management, Azure Application Gateway

AllBU=$(az account list --all -o tsv --query "[].name")
for BUname in $AllBU
do
    az account set --name $BUname
    sid=$(az account show  --name $BUname -o tsv --query id)
    echo "#############################################################################################"
    echo "Get the status of Azure API Management"
    echo "#############################################################################################"
    echo "APIM_name, resourceGroup, region, ZoneEnabled, SKU_Name, SKU_Capacity, ResourceID"
    az graph query -q "resources| where subscriptionId =='$sid' | where type == 'microsoft.apimanagement/service' | project name, resourceGroup, zones, sku.name, sku.capacity, id" -o tsv --query "data[].{name:name, resourceGroup:resourceGroup, zones:zones, sku_name:sku_name, sku_capacity:sku_capacity, location:location, ResourceId:id}" | sed 's/\t/,/g' | sed 's|^|'$BUname,'|g'
    echo "#############################################################################################"
    echo "Get the status of Azure AppGateway"
    echo "#############################################################################################"
    echo "gateway_name, resourceGroup, region, ZoneEnabled, Tier, Capacity, Generation, OpertaionalState, ResourceID"
    # Work in progress
    az graph query -q "resources| where subscriptionId =='$sid' | where type == 'microsoft.network/applicationgateways' | project name, resourceGroup, zones, properties.sku.tier, properties.sku.capacity,properties.sku.family, properties.operationalState, id" -o tsv --query "data[].{name:name, resourceGroup:resourceGroup, zones:zones, sku_name:sku_name, sku_capacity:sku_capacity, location:location, ResourceId:id}" | sed 's/\t/,/g' | sed 's|^|'$BUname,'|g'

done
