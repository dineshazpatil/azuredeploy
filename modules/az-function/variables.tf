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

variable "api_publisher_org_name" {
  description = "Provide company name of api owner"
  type        = string
}

variable "api_publisher_email" {
  description = "Provide owner email id for api"
  type        = string
}

variable "password" {
  description = "certificate password"
  default     = "password"
}

variable "appversion" {
  description = "provide app version"
  type        = string

}