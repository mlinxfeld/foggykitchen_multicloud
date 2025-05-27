variable "resource_group_name1" {
  description = "The name of the Azure Resource Group where resources will be created"
  type        = string
}

variable "resource_group_name2" {
  description = "The name of the Azure Resource Group where resources will be created"
  type        = string
}

variable "location1" {
  description = "Azure region 1 (e.g., West Europe)"
  type        = string
}

variable "location2" {
  description = "Azure region2 (e.g., East Europe)"
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
  default     = 2 # <- reduced to one just to speed up the deployment
}

variable "disk_size_gb" {
  description = "Size of the Azure managed disk"
  type        = number
  default     = 50
}

variable "disk_sku" {
  description = "The SKU of the managed disk"
  type        = string
  default     = "Premium_LRS"
}

variable "use_zones" {
  description = "Whether to deploy disks into availability zones"
  type        = bool
  default     = true
}

variable "storage_quota_gb" {
  default     = 100
  description = "Quota for the Azure Files NFS share in GB"
}

variable "my_public_ip" {
  description = "Your current public IP address for firewall exception"
  type        = string
}

variable "pg_admin_username" {
  description = "Administrator login for PostgreSQL Flexible Server"
  type        = string
  default     = "pgadmin"
}

variable "pg_admin_password" {
  description = "Administrator password for PostgreSQL Flexible Server"
  type        = string
  #sensitive   = true
}