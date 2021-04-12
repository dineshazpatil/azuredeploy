resource "azurerm_storage_account" "funcstorage" {
  name                     = "${var.project}${var.environment}storage"
  resource_group_name      = var.resourcegroupname
  location                 = var.regionname
  account_tier             = "standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "appstg_container" {
  name                  = "${var.project}${var.environment}func"
  storage_account_name  = azurerm_storage_account.funcstorage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "appstg_blob" {
  name                   = "${var.project}${var.environment}func.zip"
  storage_account_name   = azurerm_storage_account.funcstorage.name
  storage_container_name = azurerm_storage_container.appstg_container.name
  type                   = "Block"
  source                 = "${var.project}${var.environment}.zip"
}

data "azurerm_storage_account_sas" "stg_sas" {
  connection_string = azurerm_storage_account.funcstorage.primary_connection_string
  https_only        = false
  resource_types {
    service   = false
    container = false
    object    = true
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  start  = "2021-04-11"
  expiry = "2022-04-11"
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}


resource "azurerm_app_service_plan" "azfuncsp" {
  name                = "${var.project}-${var.environment}-asp"
  location            = var.regionname
  resource_group_name = var.resourcegroupname
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }

}

resource "azurerm_function_app" "azfuncapp" {
  name                       = "${var.project}-${var.environment}-app"
  location                   = var.regionname
  resource_group_name        = var.resourcegroupname
  app_service_plan_id        = azurerm_app_service_plan.azfuncsp.id
  storage_account_name       = azurerm_storage_account.funcstorage.name
  storage_account_access_key = azurerm_storage_account.funcstorage.primary_access_key
  https_only                 = true
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" : "~14",
    "FUNCTIONS_EXTENSION_VERSION" : "~3",
    "HASH"                        = "${filesha256("${var.project}${var.environment}.zip")}",
    "FUNCTIONS_WORKER_RUNTIME"    = var.azfunctionruntime,
    "AzureWebJobsDisableHomepage" = "true",
    "WEBSITE_RUN_FROM_PACKAGE" : "https://${azurerm_storage_account.funcstorage.name}.blob.core.windows.net/${azurerm_storage_container.appstg_container.name}/${azurerm_storage_blob.appstg_blob.name}${data.azurerm_storage_account_sas.stg_sas.sas}",
  }
  version = "~3"
  site_config {
    use_32_bit_worker_process = false
  }

}

resource "azurerm_app_service_custom_hostname_binding" "funcadddomain" {
  hostname            = var.domainname
  app_service_name    = azurerm_function_app.azfuncapp.name
  resource_group_name = var.resourcegroupname

}

data "azurerm_client_config" "current" {
}

resource "azurerm_api_management" "azapim" {
  name                = "${var.project}-${var.environment}-apim"
  location            = var.regionname
  resource_group_name = var.resourcegroupname
  publisher_name      = "My Company"
  publisher_email     = "company@terraform.io"

  sku_name = "Developer_1"

}

resource "azurerm_api_management_certificate" "apim_cert" {
  name                = "${var.project}-${var.environment}-apim-cert"
  api_management_name = azurerm_api_management.azapim.name
  resource_group_name = var.resourcegroupname
  data                = filebase64("./appcerts/certificate.pfx")
  password = var.password
}

resource "azurerm_api_management_custom_domain" "apim_custom_domain" {
  api_management_id = azurerm_api_management.azapim.id

    Gateway {
    host_name    = var.domainname
    certificate = filebase64("./appcerts/certificate.pfx")
    certificate_password = var.password

  }
  
  
}

resource "azurerm_api_management_api" "apim_public" {
  name                  = "${var.project}-${var.environment}-apim-public"
  api_management_name   = azurerm_api_management.azapim.name
  resource_group_name   = var.resourcegroupname
  revision              = "1"
  display_name          = "Public"
  path                  = ""
  protocols             = ["https"]
  service_url           = "https://${azurerm_function_app.azfuncapp.default_hostname}/api"
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "apim_api_op_public_hello_world" {
  operation_id        = "public-hello-world"
  api_name            = azurerm_api_management_api.apim_public.name
  api_management_name = azurerm_api_management.azapim.name
  resource_group_name = var.resourcegroupname
  display_name        = "Hello World API endpoint"
  method              = "GET"
  url_template        = "/hello-world"
}

