You won't get public IP on console after applying 'terraform apply'

Go to Azure Portal and search the created VM. You should see Public IP. 

How to test NSG Rules.
Using 'git bash' on laptop, try to do shh to Azure VM. It should work as we have allowed ssh on port 22.
ssh azureuser@<VM_Public_IP>

Then open browser and paste public ip. It will not work as port 80 is Not Allowed.

Now, go to Azure Portal and search the NSG and delete the 80 Deny Rule and add new Inbound 80 allowed rule.
Then open browser and paste public ip. It should work as port 80 is Allowed now.



