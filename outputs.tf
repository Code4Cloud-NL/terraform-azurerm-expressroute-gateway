output "vpn_gateway_id" {
  description = "The resource ID of the virtual network gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "vpn_gateway_public_ip" {
  description = "The public IP(s) of the virtual network gateway."
  value       = flatten(concat([azurerm_public_ip.pip_vgw.ip_address], [var.virtual_network_gateway.active_active != null ? azurerm_public_ip.pip_vgw_aa[*].ip_address : null]))
}

output "erc_service_keys" {
  description = "The service keys needed by the service provider to provision the expressroute circuit(s)."
  value = {
    for k, v in azurerm_express_route_circuit.this : k => {
      name        = v.name
      service_key = v.service_key
    }
  }
}
