variable "resourcegroupname" {
  description = "Resource group name"
  type        = string
}

variable "regionname" {
  description = "Provide location for azure resource"
  type        = string
}

variable "azfuncappname" {
  description = "Give name of the function app "
  type        = string
}

variable "azfunctionruntime" {
  description = "Provide runtime for the azure function line node/python/dotnet"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domainname" {
  description = "Provide the custom domain name want to add"
  type        = string
} 