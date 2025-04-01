resource "oci_load_balancer" "foggykitchen_loadbalancer" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = oci_identity_compartment.foggykitchen_compartment.id
  subnet_ids = [
    oci_core_subnet.foggykitchen_lb_sub.id
  ]
  display_name = "foggykitchen_loadbalancer"
}

resource "oci_load_balancer_listener" "foggykitchen_loadbalancer" {
  load_balancer_id         = oci_load_balancer.foggykitchen_loadbalancer.id
  name                     = "foggykitchen_loadbalancer"
  default_backend_set_name = oci_load_balancer_backendset.foggykitchen_loadbalancer_backendset.name
  port                     = 80
  protocol                 = "HTTP"
}

resource "oci_load_balancer_backendset" "foggykitchen_loadbalancer_backendset" {
  name             = "foggykitchen_lb_backendset"
  load_balancer_id = oci_load_balancer.foggykitchen_loadbalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_backend" "foggykitchen_loadbalancer_backend" {
  count            = var.node_count
  load_balancer_id = oci_load_balancer.foggykitchen_loadbalancer.id
  backendset_name  = oci_load_balancer_backendset.foggykitchen_loadbalancer_backendset.name
  ip_address       = oci_core_instance.foggykitchen_backend_vm[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
