output "azfunctionid" {
  description = "ID of the Azure function"
  value       = azurerm_function_app.azfuncapp.id
}

output "azfunctionhostname" {
  description = "Hostname of the azurefunction"
  value       = azurerm_function_app.azfuncapp.default_hostname
}
