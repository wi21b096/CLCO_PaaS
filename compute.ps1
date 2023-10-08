# winget install git.git # install git
# az login --use-device-code
# git clone https://github.com/dmelichar/clco-demo # one time clone of webapp
cd .\clco-demo\ # change directory for webapp up upload
az webapp up --runtime PYTHON:3.9 --sku B1 --location westeurope --resource-group clco_grp6 --name clco-grp6-webapp-1 --plan clco-grp6-appsvcplan
az webapp up --runtime PYTHON:3.9 --sku B1 --location westeurope --resource-group clco_grp6 --name clco-grp6-webapp-2 --plan clco-grp6-appsvcplan
az webapp up --runtime PYTHON:3.9 --sku B1 --location westeurope --resource-group clco_grp6 --name clco-grp6-webapp-3 --plan clco-grp6-appsvcplan
# az webapp log config --web-server-logging filesystem --name clco-grp6-webapp --resource-group clco_grp6 # configure logging
# az webapp log tail --name clco-grp6-webapp --resource-group clco_grp6 # real-time monitoring of logs
# az group delete --name clco_grp6 # delete azure group