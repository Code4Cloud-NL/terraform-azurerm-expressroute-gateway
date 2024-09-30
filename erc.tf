# create expressroute circuits
resource "azurerm_express_route_circuit" "this" {
  for_each = { for erc in var.expressroute_circuits : "${erc.name}-${erc.instance}" => erc }

  name                = lower("${var.general.prefix}-erc-${each.value.name}-${local.suffix}-${each.value.instance}")
  location            = var.general.location
  resource_group_name = var.general.resource_group.name
  tags                = var.tags

  sku {
    tier   = each.value.sku_tier
    family = each.value.sku_family
  }

  peering_location      = each.value.peering_location
  service_provider_name = each.value.service_provider_name
  bandwidth_in_mbps     = each.value.bandwidth_in_mbps

  lifecycle {
    ignore_changes = [tags]
  }
}

# configure private peering on expressroute circuits
resource "azurerm_express_route_circuit_peering" "private" {
  for_each = { for erc in var.expressroute_circuits : "${erc.name}-${erc.instance}" => erc if erc.operational == true }

  resource_group_name           = var.general.resource_group.name
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.this[each.key].name
  vlan_id                       = each.value.azure_private_peering.vlan_id
  primary_peer_address_prefix   = each.value.azure_private_peering.primary_peer_address_prefix
  secondary_peer_address_prefix = each.value.azure_private_peering.secondary_peer_address_prefix
  ipv4_enabled                  = true
  peer_asn                      = 209819
}

# connect expressroute circuits to virtual network gateway
resource "azurerm_virtual_network_gateway_connection" "expressroute" {
  for_each = { for erc in var.expressroute_circuits : "${erc.name}-${erc.instance}" => erc if erc.operational == true }

  name                       = lower("${var.general.prefix}-con-erc-${each.value.name}-${local.suffix}-${each.value.instance}")
  location                   = var.general.location
  resource_group_name        = var.general.resource_group.name
  tags                       = var.tags
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  type                       = "ExpressRoute"
  express_route_circuit_id   = azurerm_express_route_circuit.this[each.key].id

  lifecycle {
    ignore_changes = [tags]
  }
}
