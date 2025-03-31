# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
  is_bastion_vm_flexible_shape = contains(local.compute_flexible_shapes, var.bastion_vm_shape)
  is_backend_vm_flexible_shape = contains(local.compute_flexible_shapes, var.backend_vm_shape)
}
