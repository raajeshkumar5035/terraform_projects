# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "terraform_azure"
  location = "eastasia"
}

resource "azurerm_ssh_public_key" "name" {
  name                = "azure_terraform"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMhi9wOIiaJR8olVJX4aYLHnyA8gepxs8KMIIHewjk+aYQvxOdbddif9AAI55WbB03a37+1SvkrB8zSO6Qh/alTmPy6chjnY0tlNym6PLOzf3JwzlY62tv6aJa83SNumQLjeUlYeUH6o/9oJ34SpntVw0DJsVT06CdZ9GJQyExUp5ldGujOiU8kiBLsgZzZqAjYasIjcha8tr5/o898JKhmaBZzilP0sIM6tTAdTdxwIYxdk0wIWAe3WZHFB0BwuysStBrqh1UeT8WLS8ZyhT0gzHnEs15z8CWXqLksCriU39xrqkGX5RF0O2C5+Rk/X3XBl3ZEW9O/LkinP801IVz"

}

resource "azurerm_virtual_network" "main" {
  name                = "azure_terraform_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                = "internal"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "terraform-public"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "terraform_azure_ni"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
resource "azurerm_network_interface" "internal" {
  name                = "terraform_azure_interface"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "sshserver" {
  name                = "practice1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 100
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }
}
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.sshserver.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "azuretest"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "terraform"
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]
  admin_ssh_key {
    username   = "terraform"
    public_key= azurerm_ssh_public_key.name.public_key
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