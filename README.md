<!-- BEGIN_TF_DOCS -->
# Azure ExpressRoute gateway module

This module simplifies the creation of Azure ExpressRoute gateway and (optional) one or more ExpressRoute Circuits (connections). It is designed to be flexible, modular, and easy to use, ensuring a seamless Azure ExpressRoute gateway deployment.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_express_route_circuit.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) | resource |
| [azurerm_express_route_circuit_peering.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_public_ip.pip_vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.pip_vgw_aa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.expressroute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_expressroute_circuits"></a> [expressroute\_circuits](#input\_expressroute\_circuits) | (optional) List of expressroute circuits to connect to the virtual network gateway. | <pre>list(object({<br>    name                  = string<br>    peering_location      = string<br>    service_provider_name = string<br>    bandwidth_in_mbps     = number<br>    instance              = optional(string, "001")<br>    sku_tier              = optional(string, "Standard")<br>    sku_family            = optional(string, "MeteredData")<br>    operational           = optional(bool, false)<br>    azure_private_peering = optional(object({<br>      vlan_id                       = number<br>      primary_peer_address_prefix   = string<br>      secondary_peer_address_prefix = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_gateway_subnet"></a> [gateway\_subnet](#input\_gateway\_subnet) | (Required) The gateway subnet for the virtual network gateway (must be set via a module or data source). | <pre>object({<br>    id = string<br>  })</pre> | n/a | yes |
| <a name="input_general"></a> [general](#input\_general) | (required) General configuration used for naming resources, location etc. | <pre>object({<br>    prefix      = string<br>    application = string<br>    environment = string<br>    location    = string<br>    resource_group = object({<br>      name = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) The tags that will be applied once during the creation of the resources. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_gateway"></a> [virtual\_network\_gateway](#input\_virtual\_network\_gateway) | (Optional) Change the virtual network gateway configuration. | <pre>object({<br>    instance      = optional(string, "001")<br>    sku           = optional(string, "Standard")<br>    active_active = optional(bool, false)<br>    enable_bgp    = optional(bool, false)<br>    bgp_settings = optional(object({<br>      asn                   = optional(string, "65515")<br>      peer_weight           = optional(number)<br>      ip_configuration_name = optional(string)<br>      apipa_addresses       = optional(list(string), [])<br>    }))<br>    custom_route = optional(object({<br>      address_prefixes = list(string)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_vpn_client_configuration"></a> [vpn\_client\_configuration](#input\_vpn\_client\_configuration) | (optional) Enable and configure the point-to-site VPN on the virtual network gateway. | <pre>object({<br>    address_space        = list(string)<br>    aad_tenant           = optional(string)<br>    aad_audience         = optional(string)<br>    vpn_client_protocols = optional(list(string), ["OpenVPN"])<br>    vpn_auth_types       = optional(list(string), ["AAD"])<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_erc_service_keys"></a> [erc\_service\_keys](#output\_erc\_service\_keys) | The service keys needed by the service provider to provision the expressroute circuit(s). |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | The resource ID of the virtual network gateway. |
| <a name="output_vpn_gateway_public_ip"></a> [vpn\_gateway\_public\_ip](#output\_vpn\_gateway\_public\_ip) | The public IP(s) of the virtual network gateway. |

## Example(s)

### Azure ExpressRoute gateway with default options and 1 ExpressRoute Circuit (connection)

```hcl
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
```

 ### Azure ExpressRoute gateway with default options, 1 ExpressRoute circuit (connection) and user (point-to-site) VPN

```hcl
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

  vpn_client_configuration = {                             # (optional) enable and configure the point-to-site vpn on the virtual network gateway
    address_space = ["10.15.0.0/16"]                       # (required) the address space for the vpn clients
    aad_tenant    = "00000000-0000-0000-0000-000000000000" # (required) the tenant id of the azure ad tenant
    aad_audience  = "00000000-0000-0000-0000-000000000000" # (required) the application id of the azure vpn enterprise application (this needs to be created first)
  }

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
```

# Known issues and limitations

No known issues or limitations.

# Author

Stefan Vonk (vonk.stefan@live.nl) Technical Specialist
<!-- END_TF_DOCS -->