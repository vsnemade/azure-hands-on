Goal: Create a Load Balancer that routes HTTP traffic to two B1S Linux VMs, each running Apache. You'll access the load balancer via its public IP and see alternating responses from the two VMs.
Its very easy to understand this demo using az cmds as given below

az group create --name NSG-Test-RG --location centralindia

az network vnet create \
  --resource-group NSG-Test-RG \
  --name NSG-VNet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name NSG-Subnet \
  --subnet-prefix 10.0.1.0/24


az network nsg create \
  --resource-group NSG-Test-RG \
  --name NSG-Demo


az network nsg rule create \
  --resource-group NSG-Test-RG \
  --nsg-name NSG-Demo \
  --name Allow-SSH \
  --protocol Tcp \
  --direction Inbound \
  --priority 1000 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --access Allow


az network nsg rule create \
  --resource-group NSG-Test-RG \
  --nsg-name NSG-Demo \
  --name Allow-HTTP \
  --protocol Tcp \
  --direction Inbound \
  --priority 1010 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow

az network nic create \
  --resource-group NSG-Test-RG \
  --name vm1-nic \
  --vnet-name NSG-VNet \
  --subnet NSG-Subnet \
  --network-security-group NSG-Demo
  
az network nic create \
  --resource-group NSG-Test-RG \
  --name vm2-nic \
  --vnet-name NSG-VNet \
  --subnet NSG-Subnet \
  --network-security-group NSG-Demo
  
az vm create \
  --resource-group NSG-Test-RG \
  --name NSGTestVM1 \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --nics vm1-nic

az vm create \
  --resource-group NSG-Test-RG \
  --name NSGTestVM2 \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --nics vm2-nic
  
# We need to install dummy apache server so need public IP to do ssh on VM. 
az network public-ip create \
  --resource-group NSG-Test-RG \
  --name myPublicIP1 \
  --sku Standard \
  --allocation-method Static \
  --location centralindia


az network nic ip-config update \
  --resource-group NSG-Test-RG \
  --nic-name vm1-nic \
  --name ipconfig1 \
  --public-ip-address myPublicIP1
  
az network public-ip create \
  --resource-group NSG-Test-RG \
  --name myPublicIP2 \
  --sku Standard \
  --allocation-method Static \
  --location centralindia


az network nic ip-config update \
  --resource-group NSG-Test-RG \
  --nic-name vm2-nic \
  --name ipconfig1 \
  --public-ip-address myPublicIP2

az network public-ip create \
  --resource-group NSG-Test-RG \
  --name lb2-public-ip \
  --sku Standard \
  --allocation-method Static
  
az network lb create \
  --resource-group NSG-Test-RG \
  --name vish-lb \
  --sku Standard \
  --public-ip-address lb2-public-ip \
  --frontend-ip-name lb-frontend\
  --backend-pool-name lb-backend-pool
  
az network nic ip-config address-pool add \
  --address-pool lb-backend-pool \
  --ip-config-name ipconfig1 \
  --nic-name vm1-nic \
  --resource-group NSG-Test-RG \
  --lb-name vish-lb
  
az network nic ip-config address-pool add \
  --address-pool lb-backend-pool \
  --ip-config-name ipconfig1 \
  --nic-name vm2-nic \
  --resource-group NSG-Test-RG \
  --lb-name vish-lb
  
az network lb probe create \
  --resource-group NSG-Test-RG \
  --lb-name vish-lb \
  --name http-probe \
  --protocol Http \
  --port 80 \
  --path / \
  --interval 15 \
  --threshold 4  
  
az network lb rule create \
  --resource-group NSG-Test-RG \
  --lb-name vish-lb \
  --name http-rule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name lb-frontend \
  --backend-pool-name lb-backend-pool \
  --probe-name http-probe


--------------------------------------------
#Install apache in VMs
ssh -v azureuser@<VM1_PUBLIC_IP>
sudo apt update && sudo apt install apache2 -y
echo "Hello from VM1" | sudo tee /var/www/html/index.html
exit
#Another VM
ssh -v azureuser@<VM2_PUBLIC_IP>
sudo apt update && sudo apt install apache2 -y
echo "Hello from VM2" | sudo tee /var/www/html/index.html
exit


---------------------------
If Load Balancer is not working  check value of Path in Health probes. It is getting crap value 'C:/Program Files/<user>'. It should be just '/'
