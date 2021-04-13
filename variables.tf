variable "project" {
  description = "Project name"
  type        = string
  default     = "testnodeapp"
}

variable "apppath" {
  description = "provide the app folder name with respect to main root directory"
  type        = string
  default     = "app"
}

variable "appversion" {
  description = "provide app version"
  type        = string
  default     = "v4"

}

variable "environment" {
  description = "Provide environment name"
  type        = string
  default     = "dev"
}



variable "regionname" {
  description = "Provide location for azure resource"
  type        = string
  default     = "East US"
}


