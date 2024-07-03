data "azurerm_managed_disk" "emg_disk" {
  name                = "vm-ems-spec-devops-dev-01_OsDisk_1_1f5753acf968475295e535b559aeb6c5"
  resource_group_name = "RG-EMS-SPEC-DEVOPS-DEV-01"
}

data "azurerm_resource_group" "rg" {
  name = "rg-ems-spec-devops-dev-01"
}

resource "azurerm_snapshot" "snap" {
  name                = "vm-ems-spec-devops-dev-12-snapshot"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  create_option       = "Copy"
  source_uri          = data.azurerm_managed_disk.emg_disk.id
#   network_access_policy = "DenyAll"
#   public_network_access_enabled = false
}

# resource "azurerm_resource_group" "name" {
#     provider = azurerm.subscription2
#   name     = "test-2"
#   location = "france central"
# }

resource "azurerm_managed_disk" "source" {
    provider = azurerm.subscription2
  name                 = "acctestmd1"
  location             = data.azurerm_resource_group.name.location
  resource_group_name  = data.azurerm_resource_group.name.name
  storage_account_type = "Standard_LRS"
  create_option        = "Import"
  source_resource_id = azurerm_snapshot.snap.id
  security_type = "ConfidentialVM_VMGuestStateOnlyEncryptedWithPlatformKey"
  trusted_launch_enabled = false
  # image_reference_id = azurerm_snapshot.snap.id
  source_uri = azurerm_snapshot.snap.source_uri
  public_network_access_enabled = false
  network_access_policy = "DenyAll"
  storage_account_id = azurerm_snapshot.snap.source_uri
}

data "azurerm_resource_group" "name" {
    provider = azurerm.subscription2
  name = "rg-ems-sb-ppr-02"
}

data "azurerm_virtual_network" "name" {
    provider = azurerm.subscription2
  name = "vnet-spoke-emdcespprd001-prod-fc-001"
  resource_group_name = "rg-management-prod-fc"
}

data "azurerm_subnet" "name" {
    provider = azurerm.subscription2
  name = "pep-backend-snet"
  virtual_network_name = data.azurerm_virtual_network.name.name
  resource_group_name = "rg-management-prod-fc"
}

resource "azurerm_network_interface" "example" {
    provider = azurerm.subscription2
  name                = "example-nic"
  location            = data.azurerm_resource_group.name.location
  resource_group_name = data.azurerm_resource_group.name.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.name.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
    provider = azurerm.subscription2
  name  = "azurevm-test"
  location = data.azurerm_resource_group.name.location
  resource_group_name = data.azurerm_resource_group.name.name
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size = "Standard_D2s_v3"
  

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }


  storage_os_disk {
    os_type = "Windows"
    name = "acctestmd1"
    # managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "Attach"
    managed_disk_id   = azurerm_managed_disk.source.id
    
  }
  os_profile_linux_config {
    disable_password_authentication = false 
  }
}

