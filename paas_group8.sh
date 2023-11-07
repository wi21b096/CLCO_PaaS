################### Azure Login ###################

az login --use-device-code
az account set --subscription 7d3b23f7-171d-40d3-b2a0-f0a9d98ddee0 # change subscription id to 'Azure for Students'

################### Resource Group & Deployment ###################

az group create --name clco_grp8 --location eastus
az deployment group create --name clco-grp8-deployment --resource-group clco_grp8 --template-file ./azuredeploy.json --parameters storageName=clcogrp8sto storageSKU=Standard_LRS

################### Web App Creation ###################

cd .\clco-demo\
az webapp up --runtime PYTHON:3.9 --sku B1 --location eastus --resource-group clco_grp8 --name clco-grp8-webapp-1 --plan clco-grp8-appsvcplan
cd ..
az appservice plan update --name clco-grp8-appsvcplan --resource-group clco_grp8 --number-of-workers 3 --sku B1

################### Cognitive Services Account Creation ###################
################### Terms need to be one time accepted in Azure before it is possible to use the automation ###################

az cognitiveservices account create --name clco-grp8-ai-service --kind TextAnalytics --sku S --location eastus --resource-group clco_grp8 --yes --custom-domain clco-grp8-ai-service
# az cognitiveservices account purge --name clco-grp8-ai-service --resource-group clco_grp8 --location eastus # if you need to purge it

################### Virtual Network Setup ###################

az network vnet create --resource-group clco_grp8 --location eastus --name clco_grp8_network --address-prefixes 10.0.0.0/16
az network vnet subnet create --resource-group clco_grp8 --vnet-name clco_grp8_network --name clco_grp8_network_v1 --address-prefixes 10.0.0.0/24 --delegations Microsoft.Web/serverfarms --disable-private-endpoint-network-policies false
az network vnet subnet create --resource-group clco_grp8 --vnet-name clco_grp8_network --name clco_grp8_network_v2 --address-prefixes 10.0.1.0/24 --disable-private-endpoint-network-policies true

################### Private DNS Zone Creation ###################

az network private-dns zone create --resource-group clco_grp8 --name "privatelink.cognitiveservices.azure.com"
az network private-dns link vnet create --resource-group clco_grp8 --name cognitiveservices-zonelink --zone-name privatelink.cognitiveservices.azure.com --virtual-network clco_grp8_network --registration-enabled false
az network private-endpoint create --resource-group clco_grp8 --name "cognitive-pe" --location eastus --connection-name "cognitive-connection" --private-connection-resource-id "$(az cognitiveservices account show --resource-group clco_grp8 --name clco-grp8-ai-service --query "id" --output tsv)" --group-id account --vnet-name clco_grp8_network --subnet clco_grp8_network_v2
az network private-endpoint dns-zone-group create --resource-group clco_grp8 --endpoint-name "cognitive-pe" --name "cognitive-zone" --private-dns-zone privatelink.cognitiveservices.azure.com --zone-name privatelink.cognitiveservices.azure.com

################### App Settings Configuration ###################

az resource patch --ids "/subscriptions/7d3b23f7-171d-40d3-b2a0-f0a9d98ddee0/resourceGroups/clco_grp8/providers/Microsoft.CognitiveServices/accounts/clco-grp8-ai-service" --properties "@properties.json"

az webapp vnet-integration add --resource-group clco_grp8 --name clco-grp8-webapp-1 --vnet clco_grp8_network --subnet clco_grp8_network_v1
az webapp config appsettings set --resource-group clco_grp8 --name clco-grp8-webapp-1 --settings AZ_ENDPOINT="https://privatelink.cognitiveservices.azure.com/" AZ_KEY="$(az cognitiveservices account keys list --name clco-grp8-ai-service --resource-group clco_grp8 --query "key1" --output tsv)"
az webapp update --resource-group clco_grp8 --name clco-grp8-webapp-1 --https-only

################### Create GitHub Pipeline ###################
################### One time login and authorization via GitHub ###################

# az webapp deployment github-actions add --name clco-grp8-webapp-1 --resource-group clco_grp8 --repo wi21b096/CLCO_PaaS --branch master --login-with-github