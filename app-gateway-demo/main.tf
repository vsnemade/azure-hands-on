resource "azurerm_resource_group" "rg" {
  name     = "app-gateway-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "AppGwVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "appgw" {
  name                 = "AppGwSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "BackendSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "AppGwPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "MyAppGateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
  name         = "backendPool"
  ip_addresses = [
    azurerm_network_interface.nic[0].private_ip_address,
    azurerm_network_interface.nic[1].private_ip_address
  ]
  }


  backend_http_settings {
    name                  = "httpSetting"
    protocol              = "Http"
    port                  = 80
    request_timeout       = 20
    cookie_based_affinity = "Disabled"
  }

  http_listener {
    name                           = "appGatewayHttpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "appGatewayHttpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSetting"
	priority                   = 100
  }

  tags = {
    Environment = "Dev"
  }

  depends_on = [azurerm_linux_virtual_machine.vm]
}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[count.index].id
  }
}

resource "azurerm_public_ip" "vm_pip" {
  count               = 2
  name                = "vm-pip-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "vm-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  disable_password_authentication = false
  admin_password        = "Password123!"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<EOF
#!/bin/bash
apt update
sudo apt update && sudo apt install apache2 -y
echo "Hello from VM ${count.index}" | sudo tee /var/www/html/index.html
EOF
  )

  os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
