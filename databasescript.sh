### This script is served for two purposes: 
# 1. Scan the number of databse in each instance of SQL MI
# 2. Extract databases/servers using AHB or PAYG licenses, and provide the vCores consumed by each database/server

### How to use the script
# Run the script by using the following command:
# ./databasecript.sh > result.csv
# The result will be saved in result.csv file


# Run the following command for using cloud shell
az config set extension.use_dynamic_install=yes_without_prompt

# Add Subscription Name Here #


echo "#############################################################################################"
echo "Get the status of Azure SQL MI and related database status"
echo "#############################################################################################"
echo "BU,DB_name, SQLMI_Name, vCores, resourceGroup, region, ZoneEnabled, ResourceID"
az graph query --first 1000 -q "resources \
| where type contains 'microsoft.sql/managedinstances/databases' \
| extend resourceID = split(id, '/', 8)[0] \
| extend tostring(SQLMIName=resourceID) \
| join kind = leftouter  ( resources \
| where type == 'microsoft.sql/managedinstances' \
| extend SQLMIName = tostring(name) ) on SQLMIName \
| project subscriptionId, DBName=name, SQLMIName, vCores=properties1.vCores, resourceGroup,location, ZoneEnabled=properties1.zoneRedundant,  id" -o tsv \
--query "data[].{subscriptionId:subscriptionId, DBName:DBName, SQLMIName:SQLMIName, vCores:vCores, resourceGroup:resourceGroup, location:location, ZoneEnabled:ZoneEnabled, ResourceId:id}" \
| sed 's/\t/,/g' | change_name


echo "#############################################################################################"
echo "Get the status of Azure SQL Server/Database, and whether using AHB or PAYG license"
echo "#############################################################################################"
echo "BU,DB_Name, SQLServer, resourceGroup, region, LicenseType,SKU_Name, SKU_Tier, SKU_vCores, ZoneEnabled,ResourceID"
az graph query --first 1000 -q "resources \
| where type contains 'microsoft.sql/servers/databases' \
| extend SQLServer = split(id, '/', 8)[0] \
| project subscriptionId, DB_Name=name, SQLServer, resourceGroup, region=location, LicenseType=properties.licenseType, SKU_Name=sku.name, SKU_Tier=sku.tier, SKU_vCores=sku.capacity, ZoneEnabled=properties.zoneRedundant, id" -o tsv \
--query "data[].{subscriptionId:subscriptionId, DB_Name:DB_Name, SQLServer:SQLServer, resourceGroup:resourceGroup, region:region, LicenseType:LicenseType, SKU_Name:SKU_Name, SKU_Tier:SKU_Tier, SKU_vCores:SKU_vCores, ZoneEnabled:ZoneEnabled, ResourceId:id}" \
| sed 's/\t/,/g' | change_name \
| sed 's|BasePrice|'AzureHybridBenefit'|g' \
| sed 's|LicenseIncluded|'PayAsYouGo'|g'


echo "#############################################################################################"
echo "Get the status of Azure SQL VM, and whether using AHB or PAYG license"
echo "#############################################################################################"
echo "BU,SQLVM, resourceGroup, region, LicenseType,SKUImageOffer, SKUImageSKU,Zones, VMSize,ResourceID"
az graph query --first 1000 -q "resources \
| where type contains 'microsoft.sqlvirtualmachine/sqlvirtualmachines' \
| extend same = tolower(tostring(name)) \
| join kind = leftouter ( resources \
| where type == 'microsoft.compute/virtualmachines' \
| extend same = tolower(tostring(name)) ) on same \
| project subscriptionId, name, resourceGroup, region=location, LicenseType=properties.sqlServerLicenseType, SQLImageOffer=properties.sqlImageOffer, sqlImageSKU=properties.sqlImageSku, zones=zones1, VMSize=properties1.hardwareProfile.vmSize, id" -o tsv \
--query "data[].{subscriptionId:subscriptionId, SQLVM:name, resourceGroup:resourceGroup, region:region, LicenseType:LicenseType, SQLImageOffer:SQLImageOffer, SKUImageSKU:sqlImageSKU, Zones:zones, VMSize:VMSize, ResourceId:id}" \
| sed 's/\t/,/g' | change_name \
| sed 's|AHUB|'AzureHybridBenefit'|g' \
| sed 's|PAYG|'PayAsYouGo'|g'
