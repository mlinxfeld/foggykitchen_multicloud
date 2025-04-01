variable "resource_group_name" {
  description = "The name of the Azure Resource Group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region (e.g., East US, West Europe)"
  type        = string
}

variable "vm_size" {
  description = "The size of the Azure VM"
  type        = string
  default     = "Standard_B1s"
}

variable "node_count" {
  description = "Number of backend VMs to create"
  type        = number
  default     = 2
}
