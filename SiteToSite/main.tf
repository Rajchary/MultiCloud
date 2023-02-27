
#================================> AWS Site To Site Resources  <=========================================

resource "aws_customer_gateway" "hubble_customer_gw" {
  depends_on = [
    azurerm_public_ip.hubble_sts_pip,
    azurerm_virtual_network_gateway.hubble_sts_azure_vnet_gw
  ]
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.hubble_sts_pip.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "Hubble_Customer_GW"
  }
}

resource "aws_vpn_gateway" "hubble_vpn_gw" {
  vpc_id = var.vpc_id

  tags = {
    "Name" = "Hubble_VPN_GW"
  }
}

resource "aws_vpn_connection" "hubble_sts_vpn" {
  vpn_gateway_id      = aws_vpn_gateway.hubble_vpn_gw.id
  customer_gateway_id = aws_customer_gateway.hubble_customer_gw.id
  static_routes_only  = true
  type                = "ipsec.1"
}

resource "aws_vpn_gateway_route_propagation" "default" {
  vpn_gateway_id = aws_vpn_gateway.hubble_vpn_gw.id
  route_table_id = var.route_table_id
}

resource "aws_vpn_connection_route" "default" {
  vpn_connection_id      = aws_vpn_connection.hubble_sts_vpn.id
  destination_cidr_block = var.azure_subnet_cidr
}

resource "aws_security_group" "hubble_aws_sts_sg" {
  name        = var.aws_sg_data.name
  description = var.aws_sg_data.description
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = var.aws_sg_data.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#================================> Azure Site To Site Resources  <=========================================


resource "azurerm_public_ip" "hubble_sts_pip" {
  name                = var.hubble_sts_pip_name
  location            = var.resource_rg_location
  resource_group_name = var.resource_rg_name
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_virtual_network_gateway" "hubble_sts_azure_vnet_gw" {
  depends_on = [
    azurerm_public_ip.hubble_sts_pip
  ]
  name                = var.hubble_sts_vnetGW_name
  location            = var.resource_rg_location
  resource_group_name = var.resource_rg_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1"
  generation          = "Generation1"
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hubble_sts_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.azure_gw_subnet_id
  }
}


resource "azurerm_local_network_gateway" "hubble_lngw" {
  name                = "huble_sts_lngw"
  resource_group_name = var.resource_rg_name
  location            = var.resource_rg_location
  gateway_address     = aws_vpn_connection.hubble_sts_vpn.tunnel1_address
  address_space       = [var.vpc_cidr]
}

resource "azurerm_virtual_network_gateway_connection" "hubble_vngw_conn" {
  name                = "Hubble_Azure_AWS_GateWay_Connection"
  location            = var.resource_rg_location
  resource_group_name = var.resource_rg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hubble_sts_azure_vnet_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.hubble_lngw.id
  connection_protocol        = "IKEv2"
  shared_key                 = aws_vpn_connection.hubble_sts_vpn.tunnel1_preshared_key
}

resource "azurerm_network_security_group" "hubble_sts_nsg" {
  name                = var.azure_sg_data.name
  location            = var.resource_rg_location
  resource_group_name = var.resource_rg_name

  dynamic "security_rule" {
    for_each = var.azure_sg_data.security_rule
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}