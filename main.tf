#Crear grupo
resource "azurerm_resource_group" "var" {
  name = "ResourceGroupCluster"
  location = "UKWest"
  #ukwest
}

# Crear red virtual
 resource "azurerm_virtual_network" "var" {
   name                = "netCluster"
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.var.location
   resource_group_name = azurerm_resource_group.var.name  
 }

# Crear subred
 resource "azurerm_subnet" "var" {
   name                 = "subnetCluster"
   resource_group_name  = azurerm_resource_group.var.name
   virtual_network_name = azurerm_virtual_network.var.name
   address_prefixes     = ["10.0.2.0/24"]
 }

# Crear IP Pública para el Master
 resource "azurerm_public_ip" "var_master" {
   name                         = "publicIPMaster"
   location                     = azurerm_resource_group.var.location
   resource_group_name          = azurerm_resource_group.var.name
   allocation_method            = "Dynamic"
   sku                          = "Basic"
 }

# Crear grupo de seguridad y reglas
resource "azurerm_network_security_group" "var" {
  name                = "group_security"
  location            = azurerm_resource_group.var.location
  resource_group_name = azurerm_resource_group.var.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

 # Crear interfaz de red para el Master
 resource "azurerm_network_interface" "var_master" {
   name                = "NIC_Master"
   location            = azurerm_resource_group.var.location
   resource_group_name = azurerm_resource_group.var.name

   ip_configuration {
     name                          = "NIConfig"
     subnet_id                     = azurerm_subnet.var.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.var_master.id
   }
 }

 # Conectando el grupo de seguridad a la interfaz de la red
resource "azurerm_network_interface_security_group_association" "var" {
  network_interface_id      = azurerm_network_interface.var_master.id
  network_security_group_id = azurerm_network_security_group.var.id
}

#Crear conjunto de disponibilidad para el master
resource "azurerm_availability_set" "varMaster" {
   name                         = "AvSeCluster"
   location                     = azurerm_resource_group.var.location
   resource_group_name          = azurerm_resource_group.var.name
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }

# Create virtual machine Master
resource "azurerm_linux_virtual_machine" "var" {
  name                  = "VMMaster"
  location              = azurerm_resource_group.var.location
  availability_set_id   = azurerm_availability_set.varMaster.id
  resource_group_name   = azurerm_resource_group.var.name
  network_interface_ids = [azurerm_network_interface.var_master.id]
  size               = "Standard_E2s_v3"
  admin_username        = "administrador"
  disable_password_authentication = true

  admin_ssh_key {
    username = "administrador"
    public_key = file("~/.ssh/id_rsa.pub")
    }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
   }
}



# Crear IP Pública para el NFS
 resource "azurerm_public_ip" "var_Nfs" {
   name                         = "publicIPNfs"
   location                     = azurerm_resource_group.var.location
   resource_group_name          = azurerm_resource_group.var.name
   allocation_method            = "Dynamic"
   sku                          = "Basic"
 }


# Crear interfaz de red para el NFS
resource "azurerm_network_interface" "var_Nfs" {
   name                = "NIC_Nfs"
   location            = azurerm_resource_group.var.location
   resource_group_name = azurerm_resource_group.var.name

   ip_configuration {
     name                          = "NIConfig"
     subnet_id                     = azurerm_subnet.var.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.var_Nfs.id
   }
 }

 #Crear conjunto de disponibilidad para el NFS
resource "azurerm_availability_set" "var_Nfs" {
   name                         = "AvSNfs"
   location                     = azurerm_resource_group.var.location
   resource_group_name          = azurerm_resource_group.var.name
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }

# Create virtual machine NFS
resource "azurerm_linux_virtual_machine" "var_Nfs" {
  name                  = "VMNfs"
  location              = azurerm_resource_group.var.location
  availability_set_id   = azurerm_availability_set.var_Nfs.id
  resource_group_name   = azurerm_resource_group.var.name
  network_interface_ids = [azurerm_network_interface.var_Nfs.id]
  size               = "Standard_D2s_v3"
  admin_username        = "administrador"
  disable_password_authentication = true

  admin_ssh_key {
    username = "administrador"
    public_key = file("~/.ssh/id_rsa.pub")
    }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
   }
}

# Crear IP Pública para el Worker
 resource "azurerm_public_ip" "var_Worker" {
   name                         = "publicIPWorker"
   location                     = azurerm_resource_group.var.location
   resource_group_name          = azurerm_resource_group.var.name
   allocation_method            = "Dynamic"
   sku                          = "Basic"
 }


# Crear interfaz de red para el Worker
resource "azurerm_network_interface" "var_Worker" {
   name                = "NIC_Worker"
   location            = azurerm_resource_group.var.location
   resource_group_name = azurerm_resource_group.var.name

   ip_configuration {
     name                          = "NIConfig"
     subnet_id                     = azurerm_subnet.var.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.var_Worker.id
   }
 }

 #Crear conjunto de disponibilidad para el Worker
resource "azurerm_availability_set" "var_Worker" {
   name                         = "AvsWorker"
   location                     = azurerm_resource_group.var.location
   resource_group_name          = azurerm_resource_group.var.name
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }

# Create virtual machine Worker
resource "azurerm_linux_virtual_machine" "var_Worker" {
  name                  = "VMWorker"
  location              = azurerm_resource_group.var.location
  availability_set_id   = azurerm_availability_set.var_Worker.id
  resource_group_name   = azurerm_resource_group.var.name
  network_interface_ids = [azurerm_network_interface.var_Worker.id]
  size               = "Standard_D2s_v3"
  admin_username        = "administrador"
  disable_password_authentication = true

  admin_ssh_key {
    username = "administrador"
    public_key = file("~/.ssh/id_rsa.pub")
    }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
   }
}
