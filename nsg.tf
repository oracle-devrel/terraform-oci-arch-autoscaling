## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# ATPSecurityGroup

resource "oci_core_network_security_group" "ATPSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "ATPSecurityGroup"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Rules related to ATPSecurityGroup

# EGRESS

resource "oci_core_network_security_group_security_rule" "ATPSecurityEgressGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.ATPSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  #    destination = "10.0.0.0/16"
  destination      = "10.0.1.0/24"
  destination_type = "CIDR_BLOCK"
}

# INGRESS

resource "oci_core_network_security_group_security_rule" "ATPSecurityIngressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.ATPSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  #    source = "10.0.0.0/16"
  source      = "10.0.1.0/24"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}

# WebSecurityGroup

resource "oci_core_network_security_group" "WebSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "WebSecurityGroup"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Rules related to WebSecurityGroup

# EGRESS

resource "oci_core_network_security_group_security_rule" "WebSecurityEgressATPGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.ATPSecurityGroup[0].id
  destination_type          = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "WebSecurityEgressInternetGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "10.0.0.0/24"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS

resource "oci_core_network_security_group_security_rule" "WebSecurityIngressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.0.0.0/24"

  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 5000
      min = 5000
    }
  }
}

# LBSecurityGroup

resource "oci_core_network_security_group" "LBSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "LBSecurityGroup"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Rules related to LBSecurityGroup

# EGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityEgressInternetGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

# SSHSecurityGroup

resource "oci_core_network_security_group" "SSHSecurityGroup" {
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "SSHSecurityGroup"
  vcn_id         = oci_core_virtual_network.vcn[0].id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Rules related to SSHSecurityGroup

# EGRESS

resource "oci_core_network_security_group_security_rule" "SSHSecurityEgressGroupRule" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS

resource "oci_core_network_security_group_security_rule" "SSHSecurityIngressGroupRules" {
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

