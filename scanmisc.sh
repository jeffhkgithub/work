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

echo "#############################################################################################"
echo "Get the status of ExpressRoute and VPN Gateway"
echo "#############################################################################################"
echo "BU, gatewayName, resourceGroup, region, ZoneEnabled, gatewayIPSKU, gatewayType, gatewaySKU, gatewayTier, ResourceID"
az graph query --first 1000 -q "resources  \
| where type contains 'publicIPAddresses' and isnotempty (properties.ipAddress) \
| where properties.ipConfiguration.id contains 'virtualnetworkgateway' \
| extend sid = tostring(split(split(properties.ipConfiguration.id,'virtualNetworkGateways',1), '/', 1)[0]) \
| join kind=leftouter (resources \
    | where type contains 'virtualnetworkgateway' \
    | extend  sid = tostring(name) \
    ) on sid \
| project subscriptionId, sid1, resourceGroup1, location, zones, gatewayIPSKU=sku.name, gatewayType=properties1.gatewayType, gatewaySKU=properties1.sku.name, gatewayTier=properties1.sku.tier, id=id1 \
| sort by tostring(subscriptionId)" -o tsv \
--query "data[].{subscriptionId:subscriptionId, sid1:sid1, resourceGroup1:resourceGroup1, location:location, zones:zones, gatewayIPSKU:gatewayIPSKU, gatewayType:gatewayType, gatewaySKU:gatewaySKU, gatewayTier:gatewayTier, id:id}" \
| sed 's/\t/,/g' | change_name

echo "#############################################################################################"
echo "Get the status of Azure LoadBalancer"
echo "#############################################################################################"
echo "BU,loadBalancerName, resourceGroup, location, sku_Name, sku_Tier, frontendName, ZoneEnabled, privateIP, publicIP, ResourceID"
az graph query --first 1000 -q "resources \
| where type contains 'loadbalancer' \
| extend  frontendIPConfig= properties.frontendIPConfigurations \
| mv-expand frontendIPConfig \
| project subscriptionId, name, resourceGroup, location, sku_Name=sku.name, sku_Tier=sku.tier, frontendName=frontendIPConfig.name, ZoneEnabled=frontendIPConfig.zones, privateIP=frontendIPConfig.properties.privateIPAddress, publicIP=frontendIPConfig.properties.publicIPAddress.id, id" \
-o tsv \
--query "data[].{subscriptionId:subscriptionId, name:name, resourceGroup:resourceGroup, location:location, sku_Name:sku_Name, sku_Tier:sku_TIer, frontendName:frontendName, ZoneEnabled:ZoneEnabled, privateIP:privateIP, pubicIP:publicIP, ResourceId:id}" \
| sed 's/\t/,/g' | change_name

for ((i=1000; i<=8000; i+=1000))
do
    az graph query --first 1000 --skip $i -q "resources \
    | where type contains 'loadbalancer' \
    | extend  frontendIPConfig= properties.frontendIPConfigurations \
    | mv-expand frontendIPConfig \
    | project subscriptionId, name, resourceGroup, location, sku_Name=sku.name, sku_Tier=sku.tier, frontendName=frontendIPConfig.name, ZoneEnabled=frontendIPConfig.zones, privateIP=frontendIPConfig.properties.privateIPAddress, publicIP=frontendIPConfig.properties.publicIPAddress.id, id" \
    -o tsv \
    --query "data[].{subscriptionId:subscriptionId, name:name, resourceGroup:resourceGroup,  location:location, sku_Name:sku_Name, sku_Tier:sku_TIer, frontendName:frontendName, ZoneEnabled:ZoneEnabled, privateIP:privateIP, pubicIP:publicIP, ResourceId:id}" \
    | sed 's/\t/,/g' | change_name
done

echo "#############################################################################################"
echo "Get the status of Azure Managed Disk"
echo "#############################################################################################"
echo "BU, diskName, location, resourceGroup, managedBy, ZoneRedundant, AvailableZoneLocation, sku_Name, sku_Tier, ResourceID"
az graph query --first 1000 -q "resources \
| where type contains 'microsoft.compute/disks' \
| extend ZoneRedundant = tostring(split(sku.name, '_', 1)) \
| project subscriptionId, diskName=name, location, resourceGroup, managedBy, ZoneRedundant, AvailableZoneLocation=zones, sku_Name=sku.name, sku_Tier=sku.tier, id" \
-o tsv \
--query "data[].{subscriptionId:subscriptionId, diskName:diskName, location:location, resourceGroup:resourceGroup, managedBy:managedBy, ZoneRedundant:ZoneRedundant, AvailableZoneLocation:AvailableZoneLocation, sku_Name:sku_Name, sku_Tier:sku_Tier, ResourceId:id}" \
| sed 's/\t/,/g' | change_name


for ((i=1000; i<=8000; i+=1000))
do
    az graph query --first 1000 -q "resources \
    | where type contains 'microsoft.compute/disks' \
    | extend ZoneRedundant = tostring(split(sku.name, '_', 1)) \
    | project subscriptionId, diskName=name, location, resourceGroup, managedBy, ZoneRedundant, AvailableZoneLocation=zones, sku_Name=sku.name, sku_Tier=sku.tier, id" \
    -o tsv \
    --query "data[].{subscriptionId:subscriptionId, diskName:diskName, location:location, resourceGroup:resourceGroup, managedBy:managedBy, ZoneRedundant:ZoneRedundant, AvailableZoneLocation:AvailableZoneLocation, sku_Name:sku_Name, sku_Tier:sku_Tier, ResourceId:id}" \
    | sed 's/\t/,/g' | change_name
done


echo "#############################################################################################"
echo "Get the status of Azure HDInsight"
echo "#############################################################################################"
echo "BU, Name, location, resourceGroup,  ZoneRedundant, ResourceID"
az graph query --first 1000 -q "resources \
| where type contains 'microsoft.hdinsight/clusters' \
| project subscriptionId, name, location, resourceGroup, zones, id" \
-o tsv \
--query "data[].{subscriptionId:subscriptionId, name:name, location:location, resourceGroup:resourceGroup, zones:zones, ResourceId:id}" \
| sed 's/\t/,/g' | change_name


