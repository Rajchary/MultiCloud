
#==================================>  Root locals.tf  <=============================================

locals {
  aws_security_groups = {
    site_to_site_sg = {
      name        = "SiteToSite_AWS_Azure_SG"
      description = "Site to Site security group from aws to azure"
      ingress = {
        ssh = {
          from       = 22
          to         = 22
          protocol   = "tcp"
          cidr_block = ["0.0.0.0/0"]
        }
        icmp = {
          from       = -1
          to         = -1
          protocol   = "icmp"
          cidr_block = var.vnet_cidr_block
        }
      }

    }

    frontier_sg = {
      name        = "AWS_FrontTier_SG"
      description = "Secuirty group to handle frontier application"
      ingress = {
        http = {
          from       = 80
          to         = 80
          protocol   = "tcp"
          cidr_block = ["0.0.0.0/0"]
        }
      }
    }
  }

  azure_nsg = {
    site_to_site_nsg = {
      name        = "SiteToSite_Azure_AWS_NSG"
      description = "Site to Site NSG from Azure to AWS"

      security_rule = {
        ssh = {
          name                       = "AllowSSHFromAnywhere"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        icmp = {
          name                       = "AllowIcmpFromAWSCidrBlock"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Icmp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = var.aws_subnet_cidrs[1]
          destination_address_prefix = "*"
        }
        all = {
          name                       = "DenyAnyCustomAnyInbound"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }
}