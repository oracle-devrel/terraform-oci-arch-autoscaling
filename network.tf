## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "vcn" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "web-app-vcn"
  dns_label      = "tfexamplevcn"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "nat_gw" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "nat_gateway"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_internet_gateway" "ig" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "ig-gateway"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "rt-pub" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt-table"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "rt-priv" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt-table-priv"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gw[0].id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "subnet_1" {
  count           = !var.use_existing_vcn ? 1 : 0
  cidr_block      = "10.0.0.0/24"
  display_name    = "subnet-A"
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.vcn[0].id
  dhcp_options_id = oci_core_virtual_network.vcn[0].default_dhcp_options_id
  route_table_id  = oci_core_route_table.rt-pub[0].id
  dns_label       = "subnet1"

  provisioner "local-exec" {
    command = "sleep 5"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "subnet_2" {
  count           = !var.use_existing_vcn ? 1 : 0
  cidr_block      = "10.0.1.0/24"
  display_name    = "subnet-B"
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.vcn[0].id
  dhcp_options_id = oci_core_virtual_network.vcn[0].default_dhcp_options_id
  route_table_id  = oci_core_route_table.rt-pub[0].id
  dns_label       = "subnet2"
  provisioner "local-exec" {
    command = "sleep 5"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "subnet_3" {
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = "10.0.2.0/24"
  display_name               = "subnet-C"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn[0].id
  dhcp_options_id            = oci_core_virtual_network.vcn[0].default_dhcp_options_id
  route_table_id             = oci_core_route_table.rt-priv[0].id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "subnet3"

  provisioner "local-exec" {
    command = "sleep 5"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

