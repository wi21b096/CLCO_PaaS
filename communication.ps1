# az login --use-device-code
az cognitiveservices account show --resource-group clco_grp6 --name clco-grp6-ai-service --query id --output tsv
az network vnet create --resource-group clco_grp6 --location westeurope --name clco_grp6_network --address-prefixes 10.0.0.0/16
az network vnet subnet create --resource-group clco_grp6 --vnet-name clco_grp6_network --name clco_grp6_network_v1 --address-prefixes 10.0.0.0/24 --delegations Microsoft.Web/serverfarms --disable-private-endpoint-network-policies false
az network vnet subnet create --resource-group clco_grp6 --vnet-name clco_grp6_network --name clco_grp6_network_v2 --address-prefixes 10.0.1.0/24 --disable-private-endpoint-network-policies true
az network private-dns zone create --resource-group clco_grp6 --name "privatelink.cognitiveservices.azure.com"
az network private-dns link vnet create --resource-group clco_grp6 --name cognitiveservices-zonelink --zone-name privatelink.cognitiveservices.azure.com --virtual-network clco_grp6_network --registration-enabled False
az resource patch --ids "/subscriptions/7d3b23f7-171d-40d3-b2a0-f0a9d98ddee0/resourceGroups/clco_grp6/providers/Microsoft.CognitiveServices/accounts/clco-grp6-ai-service" --properties "{ \"publicNetworkAccess\": \"Disabled\"}"
az webapp update --resource-group clco_grp6 --name clco-grp6-webapp --https-only
az webapp vnet-integration add --resource-group clco_grp6 --name clco-grp6-webapp --vnet clco_grp6_network --subnet clco_grp6_network_v1
az cognitiveservices account show --name clco-grp6-ai-service --resource-group clco_grp6 --query "properties.endpoint" --output tsv
az cognitiveservices account keys list --name clco-grp6-ai-service --resource-group clco_grp6 --query "key1" --output tsv
az webapp config appsettings set --resource-group clco_grp6 --name clco-grp6-webapp --settings AZ_ENDPOINT="https://clco-grp6-ai-service.cognitiveservices.azure.com/" AZ_KEY="ccd6315aed6842b0884b9775c5077f55"
# az group delete --name clco_grp6 # delete azure group