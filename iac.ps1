# winget install microsoft.azurecli --version 2.50.0 # install azure cli
az login --use-device-code
az account show # show subscription
az account list # list subscription / which available
az account set --subscription 7d3b23f7-171d-40d3-b2a0-f0a9d98ddee0 # change subscription id to 'Azure for Students'
az group create --name clco_grp6 --location westeurope
az deployment group create --name clco-grp6-deployment --resource-group clco_grp6 --template-file ./azuredeploy.json --parameters storageName=clcogrp6sto storageSKU=Standard_LRS
# az group delete --name clco_grp6 # delete azure group