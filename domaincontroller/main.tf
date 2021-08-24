terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

resource "azurerm_storage_account" "tf_dc_storage_account" {
  name                     = "dcsasasedemo"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tf_dc_storage_container" {
  name                  = "${var.name}-dc-storage-container"
  storage_account_name  = azurerm_storage_account.tf_dc_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tf_dc_setup_blob" {
  name                   = "${var.name}-dc-setup.ps1"
  storage_account_name   = azurerm_storage_account.tf_dc_storage_account.name
  storage_container_name = azurerm_storage_container.tf_dc_storage_container.name
  type                   = "Block"

  source_content = templatefile("${path.module}/scripts/dc-setup.ps1", {
    domain_name = var.domain_name
    domain_nb_name = var.domain_nb_name
    safemode_admin_pwd = var.password
  })
}

resource "azurerm_network_security_group" "tf_dc_nsg" {
  name                = "${var.name}-dc-nsg"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_network_security_rule" "tf_dc_nsg_rules" {
  for_each                    = local.dc_nsg_rules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.tf_dc_nsg.name
}

resource "azurerm_network_interface" "tf_dc_nic" {
  name                = "${var.name}-nic-dc"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.name}-nic-dc-cfg"
    subnet_id                     = var.sn_priv_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ip
  }
}

resource "azurerm_network_interface_security_group_association" "tf_dc_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.tf_dc_nic.id
  network_security_group_id = azurerm_network_security_group.tf_dc_nsg.id
}

resource "azurerm_windows_virtual_machine" "tf_dc" {
  name                       = "${var.name}-vm-dc"
  computer_name              = var.computer_name
  resource_group_name        = var.rg_name
  location                   = var.location
  size                       = var.vm_size
  admin_username             = var.username
  admin_password             = var.password
  allow_extension_operations = true
  enable_automatic_updates   = true

  network_interface_ids = [
    azurerm_network_interface.tf_dc_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "tf_dc_setup_script" {
  name                 = "SetupADDS"
  virtual_machine_id   = azurerm_windows_virtual_machine.tf_dc.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings           = <<SETTINGS
    {
        "fileUris": [
          "${azurerm_storage_blob.tf_dc_setup_blob.url}"
        ]
    }
SETTINGS
  protected_settings = <<SETTINGS
    {
      "storageAccountName": "${azurerm_storage_account.tf_dc_storage_account.name}",
      "storageAccountKey": "${azurerm_storage_account.tf_dc_storage_account.primary_access_key}",
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ${azurerm_storage_blob.tf_dc_setup_blob.name}"
    }
SETTINGS
}
