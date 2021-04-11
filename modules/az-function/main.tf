resource "azurerm_storage_account" "funcstorage"{
    name = "${var.project}${var.environment}storage"
    resource_group_name = var.resourcegroupname
    location = var.regionname
    account_tier = "standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "appstg_container" {
 name = "${var.project}${var.environment}func"
 storage_account_name = azurerm_storage_account.funcstorage.name
 container_access_type = "private"
}

resource "azurerm_storage_blob" "appstg_blob"{ 
 name = "${var.project}${var.environment}func.zip"
 storage_account_name = azurerm_storage_account.funcstorage.name
 storage_container_name = azurerm_storage_container.appstg_container.name
 type = "Block"
 source = "${var.project}${var.environment}.zip"
}

data "azurerm_storage_account_sas" "stg_sas" {
 connection_string = "${azurerm_storage_account.funcstorage.primary_connection_string}"
 https_only = false
resource_types {
 service = false
 container = false
 object = true
 }
services {
 blob = true
 queue = false
 table = false
 file = false
 }
start = "2021-04-11"
 expiry = "2022-04-11"
permissions {
 read = true
 write = false
 delete = false
 list = false
 add = false
 create = false
 update = false
 process = false
 }
}


resource "azurerm_app_service_plan" "azfuncsp" {
  name                = "${var.project}${var.environment}asp"
  location            = var.regionname
  resource_group_name = var.resourcegroupname
  kind                = "FunctionApp"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "azfuncapp" {
  name                       = "${var.project}${var.environment}app"
  location                   = var.regionname
  resource_group_name        = var.resourcegroupname
  app_service_plan_id        = azurerm_app_service_plan.azfuncsp.id
  storage_account_name       = azurerm_storage_account.funcstorage.name
  storage_account_access_key = azurerm_storage_account.funcstorage.primary_access_key
  https_only = true
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION": "~14",
    "FUNCTIONS_WORKER_RUNTIME" = var.azfunctionruntime,
    "AzureWebJobsDisableHomepage" = "true",
    "WEBSITE_RUN_FROM_PACKAGE"="https://${azurerm_storage_account.funcstorage.name}.blob.core.windows.net/${azurerm_storage_container.appstg_container.name}/${azurerm_storage_blob.appstg_blob.name}${data.azurerm_storage_account_sas.stg_sas.sas}",
  }
  
  site_config  {
      use_32_bit_worker_process = false
  }
   
}
