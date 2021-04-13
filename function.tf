data "archive_file" "archive_app" {
  type        = "zip"
  source_dir  = var.apppath
  output_path = "${var.project}${var.environment}${var.appversion}.zip"
}

module "az_function" {
  source                 = "./modules/az-function"
  resourcegroupname      = azurerm_resource_group.azurefunction.name
  regionname             = azurerm_resource_group.azurefunction.location
  azfuncappname          = "testnodeappfunc"
  azfunctionruntime      = "node"
  project                = var.project
  environment            = var.environment
  domainname             = "functionapp.pngsolutions.in"
  api_publisher_org_name = "Dinesh Ltd"
  api_publisher_email    = "dineshppatil@gmail.com"
  appversion = var.appversion
}



