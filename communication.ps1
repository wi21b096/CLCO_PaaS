# az login --use-device-code
az cognitiveservices account create --name clco-grp8-ai-service --kind TextAnalytics --sku B1 --location westeurope --resource-group clco_grp8 --yes
az network vnet create --resource-group clco_grp8 --location westeurope --name clco_grp8_network --address-prefixes 10.0.0.0/16
az network vnet subnet create --resource-group clco_grp8 --vnet-name clco_grp8_network --name clco_grp8_network_v1 --address-prefixes 10.0.0.0/24 --delegations Microsoft.Web/serverfarms --disable-private-endpoint-network-policies false
az network vnet subnet create --resource-group clco_grp8 --vnet-name clco_grp8_network --name clco_grp8_network_v2 --address-prefixes 10.0.1.0/24 --disable-private-endpoint-network-policies true

az network private-endpoint create --resource-group clco_grp8 --name "cognitive-pe" --location westeurope --connection-name "cognitive-connection" --private-connection-resource-id "$(az cognitiveservices account show --resource-group clco_grp8 --name clco-grp8-ai-service --query "properties.endpoint" --output tsv)" --group-id account --vnet-name clco_grp8_network --subnet clco_grp8_network_v2
az network private-endpoint dns-zone-group create --resource-group clco_grp8 --endpoint-name "cognitive-pe" --name "cognitive-zone" --private-dns-zone privatelink.cognitiveservices.azure.com --zone-name privatelink.cognitiveservices.azure.com

#az network private-dns zone create --resource-group clco_grp8 --name "privatelink.cognitiveservices.azure.com"
#az network private-dns link vnet create --resource-group clco_grp8 --name cognitiveservices-zonelink --zone-name privatelink.cognitiveservices.azure.com --virtual-network clco_grp8_network --registration-enabled False

az resource patch --ids "/subscriptions/7d3b23f7-171d-40d3-b2a0-f0a9d98ddee0/resourceGroups/clco_grp8/providers/Microsoft.CognitiveServices/accounts/clco-grp8-ai-service" --properties "{ \"publicNetworkAccess\": \"Disabled\"}"
az webapp update --resource-group clco_grp8 --name clco-grp8-webapp-1 --https-only
az webapp vnet-integration add --resource-group clco_grp8 --name clco-grp8-webapp-1 --vnet clco_grp8_network --subnet clco_grp8_network_v1
az cognitiveservices account show --name clco-grp8-ai-service --resource-group clco_grp8 --query "properties.endpoint" --output tsv
az cognitiveservices account keys list --name clco-grp8-ai-service --resource-group clco_grp8 --query "key1" --output tsv
az webapp config appsettings set --resource-group clco_grp8 --name clco-grp8-webapp-1 --settings AZ_ENDPOINT="https://clco-grp8-ai-service.cognitiveservices.azure.com/" AZ_KEY="ccd6315aed6842b0884b9775c5077f55"
# az group delete --name clco_grp8 # delete azure group