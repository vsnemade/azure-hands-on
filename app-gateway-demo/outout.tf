output "app_gateway_public_ip" {
  value       = azurerm_public_ip.appgw_pip.ip_address
  description = "Public IP of the Application Gateway"
}
