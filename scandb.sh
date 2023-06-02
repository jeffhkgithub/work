# Targe DB
# Azure Cosmos DB for MongoDB account, SQL server, SQL VM, SQL MI, Azure Cosmos DB account, Azure Database for PostgreSQL flexible Server, Azure Database for PostgreSQL signer server

#AllBU=$(az account list --all -o tsv --query "[].name")
#AllBU="TOBEADDED"
for BUname in $AllBU
do
    az account set --name $BUname
    id=$(az account show  --name $BUname -o tsv --query id)
    echo "#############################################################################################"
    echo "Get the status SQL servers"
    echo "#############################################################################################"
    allsqlid=$(az sql server list --query "[?type=='Microsoft.Sql/servers'].id" -o tsv)
    echo "BUName,ID,SKU_name,SKU_capacity,SKU_family,SKU_tier,SKU_size,SQLserver,Location,Database_Name,Type,ResourceGroup,Status,isZoneRedundant"
    for id in $allsqlid
    do 
        az sql db list --ids $id -o tsv --query "[].{SKU_name:currentSku.name, SKU_capacity:currentSku.capacity, SKU_family:currentSku.family, SKU_tier:currentSku.tier, SKU_size:currentSku.size, SQLserver:id, location:location, database_name:name, Type:type, ResourceGroup:resourceGroup, Status:status,isZoneRedundant:zoneRedundant}" | sed 's/\t/,/g' | sed 's|^|'$BUname,$id,'|g'
    done

    echo "#############################################################################################"
    echo "Get the status of PostgreSQL servers (Both Flexible and Single server)"
    echo "#############################################################################################"
    allpostgresqlflexibleid=$(az postgres flexible-server list --query "[].id" -o tsv)
    allpostgresqlsingleid=$(az postgres server list --query "[].id" -o tsv)
    echo "BUName,location,ServerName,ResourceGroup,SKUName,SKU_Tier,isRedundant,State,StorageSize,ID"    
    for id in $allpostgresqlflexibleid
    do
        az postgres flexible-server show -o tsv --ids $id --query "{location:location, ServerName:name, ResourceGroup:resourceGroup, SKU_Name:sku.name, SKU_Tier:sku.tier, isRedundant:highAvailability.mode, State:state, StorageSize:storage.storageSizeGb, id:id}" | sed 's/\t/,/g' | sed 's|^|'$BUname,$id,'|g'
    done
    for id in $allpostgresqlsingleid
    do
        az postgres server show -o tsv --ids $id --query "{location:location, ServerName:name, ResourceGroup:resourceGroup, SKU_Name:sku.name, SKU_Tier:sku.tier, isRedundant:highAvailability.mode, State:state, StorageSize:storage.storageSizeGb, id:id}" | sed 's/\t/,/g' | sed 's|^|'$BUname,$id,'|g'
    done 
    echo "#############################################################################################"
    echo "Get the status of CosmosDB"
    echo "#############################################################################################"
    echo "BUName,id,name,location,kind,isZoneRedundant"
    condition=$(az cosmosdb list -o tsv --query "[].{name:name}")
    echo $condition
    if [ ! -z "$condition"]; then
        az graph query -q "resources | where type =~ 'microsoft.documentdb/databaseaccounts' | where subscriptionId == '$id' | extend locations = (properties.locations) | mv-expand locations | project id, name, location, kind, isZoneRedundant = tostring(locations.isZoneRedundant) " -o tsv | sed 's/\t/,/g' | sed 's|^|'$BUname,'|g'
    fi
    echo "#############################################################################################"
    echo "Get the status of SQLMI"
    echo "#############################################################################################"
    echo "BUName,location,id,serverName,resourceGroup,SKU_capacity,SKU_family,SKU_tier,state,isZoneRedundant"
    az sql mi list -o tsv --query "[].{location:location, id:id, ServerName:name, resourceGroup:resourceGroup, SKU_capacity:sku.capacity, SKU_family:sku.family, SKU_tier:sku.tier, state:state, isRedundant:zoneRedundant}" | sed 's/\t/,/g' | sed 's|^|'$BUname,'|g'

done
