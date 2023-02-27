
#=====================================> Root variables.tf <================================================

#===========> Azure Variables <===========================

variable "resource_rg_name" {
  description = "Name of the resource group"
}

variable "vnet_cidr_block" {
  description = "Cidr block address range for Vnet"
}

variable "vnet_name" {
  default     = "Hubble_Azure_Vnet"
  description = "Name of the azure Virtual Network"
}

variable "azure_subnet_cirdrs" {
  description = "Address list for azure subnets"
}

variable "azure_subnet_names" {
  description = "Names for the azure subnets"
}

variable "hubble_sts_pip_name" {
  default     = "Hubble_StS_PIP"
  description = "Name of the Azure Public IP"
}

variable "hubble_sts_vnetGW_name" {
  default     = "Hubble_StS_Azure_VnetGW"
  description = "Name of the Azure Vnet GateWay"
}

#===========> AWS Variables <===========================

variable "vpc_name" {
  default     = "Hubble_Vpc"
  description = "Name of the AWS VPC"
}

variable "vpc_cidr" {
  description = "Cidr address space for AWS VPC"
}

variable "aws_subnet_names" {
  default     = ["Hubble_AWS_Frontier_Subnet", "Hubble_AWS_Midtier_Subnet"]
  description = "Names of AWS subnets"
}

variable "aws_subnet_cidrs" {
  description = "Cidr addresses for AWS subnets"
}

variable "ami_id" {
  default     = "ami-0dfcb1ef8550277af"
  description = "AMI id of the image"
}

variable "pub_key" {
  description = "Public key for AWS instances"
}