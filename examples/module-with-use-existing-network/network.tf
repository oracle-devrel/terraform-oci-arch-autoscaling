## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "my_vcn" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "myvcn"
  dns_label      = "myvcn"
}

resource "oci_core_nat_gateway" "my_nat_gw" {
  compartment_id = var.compartment_ocid
  display_name   = "nat_gateway"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_internet_gateway" "my_ig" {
  compartment_id = var.compartment_ocid
  display_name   = "ig-gateway"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_route_table" "my_rt_pub" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_rt_pub"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.my_ig.id
  }
}

resource "oci_core_route_table" "my_rt_priv" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_rt_priv"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.my_nat_gw.id
  }
}

resource "oci_core_subnet" "my_lb_subnet" {
  cidr_block      = "192.168.1.0/24"
  display_name    = "my_lb_subnet"
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.my_vcn.id
  dhcp_options_id = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  route_table_id  = oci_core_route_table.my_rt_pub.id
  dns_label       = "pubsub1"
}

resource "oci_core_subnet" "my_compute_subnet" {
  cidr_block      = "192.168.2.0/24"
  display_name    = "my_compute_subnet"
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.my_vcn.id
  dhcp_options_id = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  route_table_id  = oci_core_route_table.my_rt_pub.id
  dns_label       = "pubsub2"
}

resource "oci_core_subnet" "my_atp_subnet" {
  cidr_block                 = "192.168.3.0/24"
  display_name               = "my_atp_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  route_table_id             = oci_core_route_table.my_rt_priv.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "privsub"
}

