### Provisioning to Azure services

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-dobrozhan" {
  name     = "rg-dobrozhan"
  location = "westeurope"
}

resource "azurerm_network_security_group" "nsg-dobrozhan" {
  name                = "nsg-dobrozhan"
  location            = azurerm_resource_group.rg-dobrozhan.location
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

#create the virtual network

resource "azurerm_virtual_network" "vnet-dobrozhan" {
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  location            = "westeurope"
  name                = "dev"
  address_space       = ["10.0.0.0/16"]
}

#create 2 subnets within the virtual network

resource "azurerm_subnet" "subnet1-dobrozhan" {
  resource_group_name  = azurerm_resource_group.rg-dobrozhan.name
  virtual_network_name = azurerm_virtual_network.vnet-dobrozhan.name
  name                 = "devsubnet-1"
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_subnet" "subnet2-dobrozhan" {
  resource_group_name  = azurerm_resource_group.rg-dobrozhan.name
  virtual_network_name = azurerm_virtual_network.vnet-dobrozhan.name
  name                 = "devsubnet-2"
  address_prefixes     = ["10.0.40.0/24"]
}

#create the network interfaces for VM and LB

resource "azurerm_public_ip" "pub_ip-1" {
  name                = "vmpubip-1"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pub_ip-2" {
  name                = "vmpubip-2"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pub_ip-lb" {
  name                = "pub_ip-lb"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

# create network interface

resource "azurerm_network_interface" "vmnic1-dobrozhan" {
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  name                = "vmnic1"

  ip_configuration {
    name                          = "vmnic1-ipconf"
    subnet_id                     = azurerm_subnet.subnet1-dobrozhan.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip-1.id
  }
}

resource "azurerm_network_interface" "vmnic2-dobrozhan" {
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  name                = "vmnic2"

  ip_configuration {
    name                          = "vmnic2-ipconf"
    subnet_id                     = azurerm_subnet.subnet2-dobrozhan.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip-2.id
  }
}

# create security group association with network interface

resource "azurerm_network_interface_security_group_association" "sga-dobrozhan-1" {
  network_interface_id      = azurerm_network_interface.vmnic1-dobrozhan.id
  network_security_group_id = azurerm_network_security_group.nsg-dobrozhan.id
}

resource "azurerm_network_interface_security_group_association" "sga-dobrozhan-2" {
  network_interface_id      = azurerm_network_interface.vmnic2-dobrozhan.id
  network_security_group_id = azurerm_network_security_group.nsg-dobrozhan.id
}

##create two VMs

resource "azurerm_windows_virtual_machine" "vm-1-dobrozhan" {
  name                = "vm-1-dobrozhan"
  location            = "westeurope"
  zone                = "2"
  size                = "Standard_DS1_v2"
  admin_username      = "dobrozhan"
  admin_password      = "flatronl1953S;"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name

  network_interface_ids = [azurerm_network_interface.vmnic1-dobrozhan.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm-2-dobrozhan" {
  name                = "vm-2-dobrozhan"
  location            = "westeurope"
  zone                = "3"
  size                = "Standard_DS1_v2"
  admin_username      = "dobrozhan"
  admin_password      = "flatronl1953S;"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name

  network_interface_ids = [azurerm_network_interface.vmnic2-dobrozhan.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# create load balancer

resource "azurerm_lb" "lb-dobrozhan" {
  name                = "lb-dobrozhan"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddressLB"
    public_ip_address_id = azurerm_public_ip.pub_ip-lb.id
  }
}

# create backend address pool

resource "azurerm_lb_backend_address_pool" "beap-dobrozhan" {
  name            = "beap-dobrozhan"
  loadbalancer_id = azurerm_lb.lb-dobrozhan.id
}

# link backend address pool with network addresses

resource "azurerm_lb_backend_address_pool_address" "beapa1-dobrozhan" {
  name                    = "beapa1-dobrozhan"
  backend_address_pool_id = azurerm_lb_backend_address_pool.beap-dobrozhan.id
  virtual_network_id      = azurerm_virtual_network.vnet-dobrozhan.id
  ip_address              = "10.0.20.4"
}

resource "azurerm_lb_backend_address_pool_address" "beapa2-dobrozhan" {
  name                    = "beapa2-dobrozhan"
  backend_address_pool_id = azurerm_lb_backend_address_pool.beap-dobrozhan.id
  virtual_network_id      = azurerm_virtual_network.vnet-dobrozhan.id
  ip_address              = "10.0.40.4"
}

# create health probe

resource "azurerm_lb_probe" "hp-dobrozhan" {
  resource_group_name = azurerm_resource_group.rg-dobrozhan.name
  loadbalancer_id     = azurerm_lb.lb-dobrozhan.id
  name                = "http-health-check"
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 5
}

# create load balancing rule

resource "azurerm_lb_rule" "lbrule-dobrozhan" {
  resource_group_name            = azurerm_resource_group.rg-dobrozhan.name
  loadbalancer_id                = azurerm_lb.lb-dobrozhan.id
  name                           = "lbrule-dobrozhan"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddressLB"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.beap-dobrozhan.id
  probe_id                       = azurerm_lb_probe.hp-dobrozhan.id
}
