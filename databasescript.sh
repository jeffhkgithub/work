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
change_name (){
  sed 's|97849348-0525-4007-9d79-11ada732dfcc|'SG01'|g' \
| sed 's|d0259ea3-0613-49b4-8bfb-f1c930e15b61|'AH01'|g' \
| sed 's|412b59ce-fbe6-4ecd-88ac-053c127481b6|'AU01'|g' \
| sed 's|6ebeb62c-b6c5-4a37-bb00-542b862f4a69|'AV01'|g' \
| sed 's|85d3379c-2a11-4b41-b33f-d61218b89b33|'DP01'|g' \
| sed 's|e8569be2-1379-4a99-a535-b2dc6b90757f|'GO01'|g' \
| sed 's|fc6e9d72-7f73-4a05-83de-44204d69d3f7|'GO02'|g' \
| sed 's|9b491dd6-598e-498c-98a0-d3bbd2290821|'HK01'|g' \
| sed 's|ec8c1d2f-05fc-44d5-8be0-7e12328bd04d|'ID01'|g' \
| sed 's|87daa139-3f3e-4f68-a606-47e3c1a9dcc0|'KH01'|g' \
| sed 's|87aa8a7e-e5e4-4161-8345-d6cb40a28cc5|'KR01'|g' \
| sed 's|c247899f-2417-42fb-8000-b3f316435dec|'KR02'|g' \
| sed 's|44483f29-3799-4152-9bf9-3e2b63a6413a|'LK01'|g' \
| sed 's|d769bca7-019c-4ac0-9409-e25c5d9f1b04|'MM01'|g' \
| sed 's|98cca47e-2dd1-41f5-8764-4ee77315ba87|'PH01'|g' \
| sed 's|bf1a52e2-fc17-4860-8d49-d9563091280f|'ST01'|g' \
| sed 's|1a950d91-3cf6-4ea2-83ae-fbba189cff4a|'TS01'|g' \
| sed 's|91d9682f-15ad-42ac-acc2-df54a6ba9bee|'VN01'|g' \
| sed 's|11692d84-d4a3-41d7-a311-782ced106e74|'BX01'|g' \
| sed 's|6013edd1-6f45-4272-8e37-ec97d36f0c7c|'MY01'|g' \
| sed 's|e1c65462-3a70-430d-87b2-93fe422a218a|'GO05'|g' \
| sed 's|da8b1752-6033-4c64-88e2-dccbd78d4307|'TW01'|g' \
| sed 's|acb08a92-a0fd-4288-8877-6efe5f2502a7|'NZ01'|g' \
| sed 's|38f6f519-c3c4-4e55-b53b-4a7a28cdaf34|'TH01'|g' 
}

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
