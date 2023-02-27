
#=====================================> Root main.tf <================================================

module "azure_network" {
  source              = "./Network/Azure_Network"
  resource_rg_name    = var.resource_rg_name
  vnet_cidr_block     = var.vnet_cidr_block
  vnet_name           = var.vnet_name
  azure_snet_count    = 2
  azure_subnet_cirdrs = var.azure_subnet_cirdrs
  azure_subnet_names  = var.azure_subnet_names
  vpc_cidr            = var.vpc_cidr
  azure_sg_data       = local.azure_nsg.site_to_site_nsg
}

module "aws_network" {
  source           = "./Network/AWS_Network"
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  aws_subnet_cidrs = var.aws_subnet_cidrs
  aws_subnet_names = var.aws_subnet_names
  aws_sg_data      = local.aws_security_groups
}

module "site_to_site" {
  source                 = "./SiteToSite"
  azure_subnet_cidr      = var.azure_subnet_cirdrs[0]
  azure_gw_subnet_id     = module.azure_network.azure_gw_subnet_id
  hubble_sts_pip_name    = var.hubble_sts_pip_name
  hubble_sts_vnetGW_name = var.hubble_sts_vnetGW_name
  vpc_id                 = module.aws_network.vpc_id
  vpc_cidr               = var.vpc_cidr
  route_table_id         = module.aws_network.route_table_id
  resource_rg_location   = module.azure_network.resource_rg_location
  resource_rg_name       = var.resource_rg_name
}

module "aws_compute" {
  source        = "./Compute/AWS_Compute"
  vpc_id        = module.aws_network.vpc_id
  ami_id        = var.ami_id
  aws_subnet_id = module.aws_network.aws_subnet_id[1]
  aws_pub_key   = var.pub_key
  aws_sg_ids    = module.aws_network.aws_sg_ids
  userData_path = "${path.root}/userData.sh"
}

module "azure_compute" {
  source                  = "./Compute/Azure_Compute"
  azure_subnet_id         = module.azure_network.azure_subnet_id
  resource_group_name     = var.resource_rg_name
  resource_group_location = module.azure_network.resource_rg_location
  azure_pub_key           = var.pub_key
  azure_nsg_id            = module.azure_network.azure_nsg_id
}