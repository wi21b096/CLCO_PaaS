az login
az cognitiveservices account show --resource-group clco_grp6 --name clco-grp6-webapp-service --query id --output tsv
az network vnet create --resource-group clco_grp6 --location westeurope --name clco_grp6_network --address-prefixes 10.0.0.0/16
az network vnet subnet create --resource-group clco_grp6 --vnet-name clco_grp6_network --name clco_grp6_network_v1 --address-prefixes 10.0.0.0/24 --delegations Microsoft.Web/serverfarms --disable-private-endpoint-network-policies false
az network vnet subnet create --resource-group clco_grp6 --vnet-name clco_grp6_network --name clco_grp6_network_v2 --address-prefixes 10.0.1.0/24 --disable-private-endpoint-network-policies true
az network private-dns zone create --resource-group clco_grp6 --name "privatelink.cognitiveservices.azure.com"
az network private-dns link vnet create --resource-group clco_grp6 --name cognitiveservices-zonelink --zone-name privatelink.cognitiveservices.azure.com --virtual-network clco_grp6_network --registration-enabled False
az resource update --ids ((((clco_grp6_network_v2))).id) --set properties.publicNetworkAccess="Disabled" # id is needed
az webapp update --resource-group clco_grp6 --name clco-grp6-webapp --https-only
az webapp vnet-integration add --resource-group clco_grp6 --name clco-grp6-webapp --vnet clco_grp6_network --subnet clco_grp6_network_v1
# Get the endpoint for the Language service resource
> endpoint=$(az cognitiveservices account show \
--name clco-grp6-webapp-service \
--resource-group clco_grp6 \
--query "properties.endpoint" \
--output tsv
)
# Get the associated key
> key=$(az cognitiveservices account keys list \
--name clco-grp6-webapp-service \
--resource-group clco_grp6 \
--query "key1" \
--output tsv
)
> az webapp config appsettings set --resource-group clco_grp6 --name clco-grp6-webapp --settings AZ_ENDPOINT="$endpoint" AZ_KEY="$key"
# az group delete --name clco_grp6 # delete azure group