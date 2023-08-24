# Add Subscription Name Here #

echo "#############################################################################################"
echo "Get the status of Azure API Management"
echo "#############################################################################################"
echo "BU,APIM_name, resourceGroup, region, ZoneEnabled, SKU_Name, SKU_Capacity, ResourceID"
az graph query --first 1000 -q "resources | where type == 'microsoft.apimanagement/service' \
| project subscriptionId, name, resourceGroup, location, zones, sku.name, sku.capacity, id" -o tsv \
--query "data[].{subscriptionId:subscriptionId, name:name, resourceGroup:resourceGroup, location:location, zones:zones, sku_name:sku_name, sku_capacity:sku_capacity,  ResourceId:id}" \
| sed 's/\t/,/g' | change_name

echo "#############################################################################################"
echo "Get the status of Azure AppGateway"
echo "#############################################################################################"
echo "BU,gateway_name, resourceGroup, region, ZoneEnabled, Tier, Capacity, Generation, OpertaionalState, ResourceID"
az graph query --first 1000 -q "resources | where type =='microsoft.network/applicationgateways' |project subscriptionId,name, resourceGroup, location, zones, properties.sku.tier, properties.sku.capacity,properties.sku.family, properties.operationalState, id" -o tsv \
 --query "data[].{subscriptionId:subscriptionId, name:name, resourceGroup:resourceGroup, Region:location, zonesEnabled:zones, sku_tier:properties_sku_tier, sku_capacity:properties_sku_capacity, generation:properties_sku_family, properties_operationalState:properties_operationalState, ResourceId:id}" \
| sed 's/\t/,/g' | change_name

echo "#############################################################################################"
echo "Get the status of Azure Recovery Vault Services"
echo "#############################################################################################"
echo "BU,RecoveryVaultName, resourceGroup, region, ZoneEnabled, SKU_Tier, SKU_Name, ResourceID"
az graph query --first 1000 -q "resources | where type == 'microsoft.recoveryservices/vaults' \
| project subscriptionId, name, resourceGroup, location, zones, sku.tier, sku.name, id" -o tsv \
--query "data[].{subscriptionId:subscriptionId, name:name, resourceGroup:resourceGroup, location:location, zones:zones, sku_tier:sku_tier, sku_name:sku_name, ResourceId:id}" \
| sed 's/\t/,/g' | change_name

echo "#############################################################################################"
echo "Get the status of Azure Container Registries"
echo "#############################################################################################"
echo "BU,RegistriesName, resourceGroup, region, ZoneEnabled, SKU_Tier, SKU_Name, ResourceID"
az graph query --first 1000 -q "resources | where type == 'microsoft.containerregistry/registries' \
| project subscriptionId, name, resourceGroup, location, properties.zoneRedundancy, sku.name, sku.tier, id" -o tsv \
--query "data[].{subscriptionId:subscriptionId, name:name, resourceGroup:resourceGroup, location:location, properties_zoneRedundancy:properties_zoneRedundancy, sku_name:sku_name, sku_tier:sku_tier, ResourceId:id}" \
| sed 's/\t/,/g' | change_name


