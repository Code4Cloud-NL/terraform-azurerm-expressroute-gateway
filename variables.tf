variable "general" {
  description = "(required) General configuration used for naming resources, location etc."
  type = object({
    prefix      = string
    application = string
    environment = string
    location    = string
    resource_group = object({
      name = string
    })
  })
  validation {
    condition     = contains(["lab", "stg", "dev", "tst", "acc", "prd"], var.general.environment)
    error_message = "Invalid environment specified!"
  }
  validation {
    condition     = contains(["northeurope", "westeurope"], var.general.location)
    error_message = "Invalid location specified!"
  }
}

variable "tags" {
  description = "(optional) The tags that will be applied once during the creation of the resources."
  type        = map(string)
  default     = {}
}

variable "gateway_subnet" {
  description = "(Required) The gateway subnet for the virtual network gateway (must be set via a module or data source)."
  type = object({
    id = string
  })
}

variable "virtual_network_gateway" {
  description = "(Optional) Change the virtual network gateway configuration."
  type = object({
    instance      = optional(string, "001")
    sku           = optional(string, "Standard")
    active_active = optional(bool, false)
    enable_bgp    = optional(bool, false)
    bgp_settings = optional(object({
      asn                   = optional(string, "65515")
      peer_weight           = optional(number)
      ip_configuration_name = optional(string)
      apipa_addresses       = optional(list(string), [])
    }))
    custom_route = optional(object({
      address_prefixes = list(string)
    }))
  })
  default = {}

  validation {
    condition     = contains(["Standard", "HighPerformance", "UltraPerformance", "ErGw1AZ", "ErGw2AZ", "ErGw3AZ"], var.virtual_network_gateway.sku)
    error_message = "Invalid sku specified. Possible values are: Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ and ErGw3AZ."
  }
}

variable "vpn_client_configuration" {
  description = "(optional) Enable and configure the point-to-site VPN on the virtual network gateway."
  type = object({
    address_space        = list(string)
    aad_tenant           = optional(string)
    aad_audience         = optional(string)
    vpn_client_protocols = optional(list(string), ["OpenVPN"])
    vpn_auth_types       = optional(list(string), ["AAD"])
  })
  default = null

  validation {
    condition = var.vpn_client_configuration == null ? true : (
      alltrue([
        for protocol in var.vpn_client_configuration.vpn_client_protocols :
      contains(["OpenVPN", "SSTP", "IKEv2"], protocol)])
    )
    error_message = "Invalid vpn client protocols. Possible values are: SSTP, IkeV2, OpenVPN."
  }
  validation {
    condition = var.vpn_client_configuration == null ? true : (
      alltrue([
        for auth_type in var.vpn_client_configuration.vpn_auth_types :
      contains(["AAD", "Radius", "Certificate"], auth_type)])
    )
    error_message = "Invalid vpn auth type. Possible values are: AAD, Radius, Certificate."
  }
}

variable "expressroute_circuits" {
  description = "(optional) List of expressroute circuits to connect to the virtual network gateway."
  type = list(object({
    name                  = string
    peering_location      = string
    service_provider_name = string
    bandwidth_in_mbps     = number
    instance              = optional(string, "001")
    sku_tier              = optional(string, "Standard")
    sku_family            = optional(string, "MeteredData")
    operational           = optional(bool, false)
    azure_private_peering = optional(object({
      vlan_id                       = number
      primary_peer_address_prefix   = string
      secondary_peer_address_prefix = string
    }))
  }))
  default = []
}
