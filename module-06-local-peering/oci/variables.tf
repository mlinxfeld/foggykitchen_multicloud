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

variable "node_count" {
  description = "Number of backend VMs to create"
  type        = number
  default     = 1
}

variable "lb_shape" {
  description = "Defines the shape of the load balancer. Use 'flexible' for dynamic scaling or specify fixed shapes like '10Mbps' or '100Mbps'."
  default     = "flexible"
}

variable "flex_lb_min_shape" {
  description = "Minimum bandwidth (in Mbps) for the flexible load balancer."
  default     = 10
}

variable "flex_lb_max_shape" {
  description = "Maximum bandwidth (in Mbps) for the flexible load balancer."
  default     = 100
}

variable "volume_size_in_gbs" {
  description = "The size of the block volume in gigabytes. Adjust this value based on your application's storage requirements."
  default     = 100
  validation {
    condition     = var.volume_size_in_gbs > 0
    error_message = "Volume size must be greater than 0 GB."
  }
}

variable "vpus_per_gb" {
  description = "The performance level of the block volume. Accepted values: 0=Low Cost, 10=Balanced, 20=HigherPerformance, or 30=UltraHighPerformance."
  default     = 10
  validation {
    condition     = contains([0, 10, 20, 30], var.vpus_per_gb)
    error_message = "Volume performance must be one of the following values: 0=Low Cost, 10=Balanced, 20=HigherPerformance, or 30=UltraHighPerformance."
  }
}

variable "mount_target_ip_address" {
  description = "The IP address of the mount target for the file storage service."
  default     = "10.0.4.25"
}

variable "fss_ingress_tcp_ports" {
  description = "List of TCP ports allowed for ingress traffic to the file storage service."
  type        = list(string)
  default     = [111, 2048, 2049, 2050]
}

variable "fss_ingress_udp_ports" {
  description = "List of UDP ports allowed for ingress traffic to the file storage service."
  type        = list(string)
  default     = [111, 2048]
}

variable "fss_egress_tcp_ports" {
  description = "List of TCP ports allowed for egress traffic from the file storage service."
  type        = list(string)
  default     = [111, 2048, 2049, 2050]
}

variable "fss_egress_udp_ports" {
  description = "List of UDP ports allowed for egress traffic from the file storage service."
  type        = list(string)
  default     = [111]
}

variable "adb_password" {
  description = "Autonomous Database ADMIN user password"
  type = string
  default = "BEstrO0ng_#11"
}
