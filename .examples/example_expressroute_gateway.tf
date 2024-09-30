module "expressroute_gateway" {
  source = "../modules/terraform-azurerm-expressroute-gateway"

  general = {                                                 # (required) general information used in the naming of resources etc.
    prefix         = "c4c"                                    # (required) the prefix of the customer (e.g. c4c)
    application    = "connectivity"                           # (required) the unique name of the vpn gateway (must be unique within the subscription)
    environment    = "prd"                                    # (required) the environment (e.g. lab, stg, dev, tst, acc, prd)
    location       = "westeurope"                             # (required) the location for the resources (e.g. westeurope, northeurope)
    resource_group = data.azurerm_resource_group.example.name # (required) the resource group for the resources (must be set via a module or data source)
  }

  tags = { # (optional) a map of tags applied to the resources
    environment = "prd"
    location    = "westeurope"
    managed_by  = "terraform"
  }

  gateway_subnet = data.azurerm_subnet.example.id # (required) the gateway subnet for the virtual network gateway (must be set via a module or data source)

  expressroute_circuits = [ # (optional) list of expressroute circuits / connections for the virtual network gateway
    {
      name                  = "equinix"   # (required) the unique name of the expressroute circuit (must be unique within the module)
      peering_location      = "Amsterdam" # (required) the peering location for the expressroute circuit
      service_provider_name = "Equinix"   # (required) the service provider for the expressroute circuit
      bandwidth_in_mbps     = 200         # (required) the bandwidth for the expressroute circuit
      operational           = false       # (required) boolean to enable the peering and connection (must be set to true AFTER the expressroute has been provisioned by the service provider)

      azure_private_peering = {                         # (optional) the azure private peering configuration for the expressroute circuit
        primary_peer_address_prefix   = "10.5.5.104/30" # (required) the ipv4 primary subnet
        secondary_peer_address_prefix = "10.5.6.108/30" # (required) the ipv4 secondary subnet
        vlan_id                       = 100             # (required) the vlan id
      }
    }
  ]
}
