variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "rg-lb-demo"
}

variable "vm_admin_username" {
  default = "azureuser"
}

variable "vm_admin_password" {
  default = "Password1234!"  # Use Key Vault or environment variables in real-world
}
