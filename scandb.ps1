# Targe DB
# Azure Cosmos DB for MongoDB account, SQL server, SQL VM, SQL MI, Azure Cosmos DB account, Azure Database for PostgreSQL flexible Server, Azure Database for PostgreSQL signer server, Azure Cache for Redis

$AllBU=$(az account list --all -o tsv --query "[].name")

foreach ($BUname in $AllBU){

    Write-Output "`n`n#############################################################################################"
    Write-Output $BUname
    az account set --name $BUname
    Write-Output "#############################################################################################"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status SQL servers"
    Write-Output "#############################################################################################"
    $allsqlid=$(az sql server list --query "[?type=='Microsoft.Sql/servers'].id" -o tsv)
    foreach ($id in $allsqlid) {
        az sql db list --ids $id -o tsv --query "[].{SKU_name:currentSku.name, SKU_capacity:currentSku.capacity, SKU_family:currentSku.family, SKU_tier:currentSku.tier, SKU_size:currentSku.size, SQLserver:id, database_name:name, Type:type, ResourceGroup:resourceGroup, Status:status,isZoneRedundant:zoneRedundant}"
    }
    Write-Output "#############################################################################################"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of PostgreSQL flexible servers"
    Write-Output "#############################################################################################"
    $allpostgresqlflexibleid=$(az postgres flexible-server list --query "[].id" -o tsv)
    foreach ($id in $allpostgresqlflexibleid) {
        az postgres flexible-server show -o tsv --ids $id --query "{ServerName:name, ResourceGroup:resourceGroup, SKU_Name:sku.name, SKU_Tier:sku.tier, isRedundant:highAvailability.mode, State:state, StorageSize:storage.storageSizeGb, id:id}"
    }
    Write-Output "#############################################################################################"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the database per PostreSQL flexible server"
    Write-Output "#############################################################################################"   
    # Use PowerQuery to combine this table to server table using server ID
    $allpostgresqlflexibleid=$(az postgres flexible-server list --query "[].id" -o tsv)
    foreach ($id in $allpostgresqlflexibleid) {
         $servermetadata=az postgres flexible-server show -o tsv --ids $id --query "[name, resourceGroup]"
         echo $id
         # Copy the $id next to each result
         az postgres flexible-server db list --server $servermetadata[0] -g $servermetadata[1] -o tsv --query "[].name"
         #$result=$id+" "+$(az postgres flexible-server db list --server $servermetadata[0] -g $servermetadata[1] -o tsv --query "[].name")
    }
    Write-Output "#############################################################################################"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of PostgreSQL single servers"
    Write-Output "#############################################################################################"   
    # PostgreSQL single server don't provide any high availability features
    $allpostgresqlsingleid=$(az postgres server list --query "[].id" -o tsv)
    foreach ($id in $allpostgresqlflexibleid) {
        az postgres server show -o tsv --ids $id --query "{ServerName:name, ResourceGroup:resourceGroup, SKU_Name:sku.name, SKU_Tier:sku.tier, isRedundant:highAvailability.mode, State:state, StorageSize_MB:storageProfile.storageMb, id:id}"
    }         

    Write-Output "#############################################################################################"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of CosmosDB account"
    Write-Output "#############################################################################################"   
    az cosmosdb list -o tsv --query "[].{name:name, location:location, kind:kind, id:id}"
    # Assume the order is correct...
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of CosmosDB account redundant (Write)"
    Write-Output "#############################################################################################"  
    az cosmosdb list -o tsv  --query "[].writeLocations[].isZoneRedundant"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of CosmosDB account redundant (read)"
    Write-Output "#############################################################################################"  
    az cosmosdb list -o tsv  --query "[].readLocations[].isZoneRedundant"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the status of Azure SQL MI"
    Write-Output "#############################################################################################"  
    az sql mi list --query "[].{location:location, id:id, ServerName:name, resourceGroup:resourceGroup, SKU_capacity:sku.capacity, SKU_family:sku.family, SKU_tier:sku.tier, state:state, isRedundant:zoneRedundant}"
    Write-Output "`n`n#############################################################################################"
    Write-Output "Get the dataabase of Azure SQL MI"
    Write-Output "#############################################################################################"  
    $allsqlmiid=$(az sql mi list --query "[].id" -o tsv)
     foreach ($id in $allsqlmiid) {
        echo $id 
        Write-Output "Copy the SQLMI ID next to it and use power query to combine"
        az sql midb list --ids $id -o tsv --query "[].{name:name, resourceGroup:resourceGroup, id:id, status:status, type:type}"
     }

}
