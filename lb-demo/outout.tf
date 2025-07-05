output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
  description = "Use this IP to access the Apache2 web server via the Load Balancer"
}
