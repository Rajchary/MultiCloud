
#=========================================> Azure_Compute main.tf <=====================================

resource "azurerm_public_ip" "vm_pip" {
  name                = "Hubble_VM_PIP"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "hubble_nic" {
  depends_on = [
    azurerm_public_ip.vm_pip
  ]
  name                = "Hubble_VM_NIC"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.azure_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "hubble_nic_nsg_ass" {
  network_interface_id      = azurerm_network_interface.hubble_nic.id
  network_security_group_id = var.azure_nsg_id
}

resource "azurerm_linux_virtual_machine" "hubble_azure_vm" {
  name                            = "HubbleVM"
  resource_group_name             = var.resource_group_name
  location                        = var.resource_group_location
  size                            = "Standard_F2"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.hubble_nic.id]
  admin_username                  = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.azure_pub_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
