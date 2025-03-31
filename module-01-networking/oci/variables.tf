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

