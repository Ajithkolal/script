 #!/bin/bash
      az login --tenant $(SUB_ID)
      az account show --output yaml
      az group create --name $(RG) --location $(LOCATION)
      az network vnet create -g $(RG) -n $(VNET) --address-prefix 10.0.0.0/16 \
                --subnet-name $(SUBNET) --subnet-prefix 10.0.0.0/24
      az network public-ip create -g $(RG) -n $(IP) --allocation-method Dynamic
      az network nsg create -g $(RG) -n $(NSG)
      az network nic create -g $(RG) --vnet-name $(VNET) --subnet $(SUBNET) -n $(NIC)
      az network nic ip-config create -g $(RG) -n testipConfig --nic-name $(NIC) --make-primary
      az vm create -n $(VM) -g $(RG) --image UbuntuLTS --public-ip-address $(IP) --authentication-type password --admin-username $(USER) --admin-password $(PASSWORD)
      az vm run-command invoke -g $(RG) -n $(VM) --command-id RunShellScript --scripts "sudo apt-get update && sudo apt-get install -y application_server"
      az vm open-port --port 80 --resource-group $(RG) --name $(VM)
      
      echo "Execute your super awesome commands here!"
      mkdir -p /home/azureuser/myagent/ /home/azureuser/Downloads 
      cd /home/azureuser/Downloads
      wget https://vstsagentpackage.azureedge.net/agent/2.204.0/vsts-agent-linux-x64-2.204.0.tar.gz
      cd /home/azureuser/myagent/
      tar zxvf /home/azureuser/Downloads/vsts-agent-linux-x64-2.204.0.tar.gz
      sudo chmod -R 777 /home/azureuser/myagent/
      runuser -l azureuser -c '/home/azureuser/myagent/config.sh --unattended  --url https://dev.azure.com/ajithonkar --auth pat --token cfqvewrtn35yc4vj7ltoc4dy7kodadhjkuqminvlbgkf4cpibvza --pool ajithpool'
      sudo /home/azureuser/myagent/svc.sh install
      sudo /home/azureuser/myagent/svc.sh start
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

