variable "tenancy_ocid" {
  description = "The OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user performing Terraform operations"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint for the API signing key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private API signing key"
  type        = string
}

variable "region" {
  description = "OCI region (e.g., us-ashburn-1)"
  type        = string
}

variable "bastion_vm_shape" {
  default = "VM.Standard.E4.Flex"
  description = "Shape for the compute instance."
}

variable "bastion_vm_flex_shape_memory" {
  description = "The amount of memory (in GB) to allocate for flexible compute shapes. This applies only to shapes that support customization."
  default = 2
}

variable "bastion_vm_flex_shape_ocpus" {
  description = "The number of OCPUs (Oracle CPUs) to allocate for flexible compute shapes. This applies only to shapes that support customization."
  default = 1
}


variable "backend_vm_shape" {
  default = "VM.Standard.E4.Flex"
  description = "Shape for the compute instance."
}

variable "backend_vm_flex_shape_memory" {
  description = "The amount of memory (in GB) to allocate for flexible compute shapes. This applies only to shapes that support customization."
  default = 2
}

variable "backend_vm_flex_shape_ocpus" {
  description = "The number of OCPUs (Oracle CPUs) to allocate for flexible compute shapes. This applies only to shapes that support customization."
  default = 1
}