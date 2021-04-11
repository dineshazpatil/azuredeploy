data "archive_file" "archive_app" {
    type = "zip"
    source_dir = "app"
    output_path = "${var.project}${var.environment}.zip"
}

module "az_function"{
    source = "./modules/az-function"

    resourcegroupname = azurerm_resource_group.azurefunction.name
    regionname = azurerm_resource_group.azurefunction.location
    azfuncappname = "testnodeappfunc"
   # functionrepourl = "https://github.com/dineshazpatil/azfunctionnodejs"
    azfunctionruntime = "node"
    project = var.project
    environment = var.environment
}



