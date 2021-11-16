## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ATP_password" {}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "oci-arch-autoscaling" {
  ## source           = "github.com/oracle-devrel/terraform-oci-arch-autoscaling"
  source            = "../../"
  tenancy_ocid      = var.tenancy_ocid
  user_ocid         = var.user_ocid
  fingerprint       = var.fingerprint
  region            = var.region
  private_key_path  = var.private_key_path
  compartment_ocid  = var.compartment_ocid
  ATP_password      = var.ATP_password
  use_existing_vcn  = true
  use_existing_nsg  = true
  vcn_id            = oci_core_virtual_network.my_vcn.id
  lb_subnet_id      = oci_core_subnet.my_lb_subnet.id
  lb_nsg_id         = oci_core_network_security_group.my_lb_nsg.id
  compute_subnet_id = oci_core_subnet.my_compute_subnet.id
  compute_nsg_id    = oci_core_network_security_group.my_compute_nsg.id
  ATP_subnet_id     = oci_core_subnet.my_atp_subnet.id
  ATP_nsg_id        = oci_core_network_security_group.my_atp_nsg.id
}

output "loadbalancer_public_url" {
  value = module.oci-arch-autoscaling.loadbalancer_public_url
}

output "generated_ssh_private_key" {
  value     = module.oci-arch-autoscaling.generated_ssh_private_key
  sensitive = true
}

