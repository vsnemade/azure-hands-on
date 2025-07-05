variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "rg-network-demo"
}

variable "vnet_name" {
  default = "demo-vnet"
}

variable "address_space" {
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  default = {
    "subnet1" = "10.0.1.0/24"
    "subnet2" = "10.0.2.0/24"
  }
}
