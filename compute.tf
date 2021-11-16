## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# This Terraform script provisions a compute instance, instance configuration, instance pool and autoscaling config.

data "template_file" "key_script" {
  template = file("${path.module}/scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
}

# Create Compute Instance

resource "oci_core_instance" "compute_instance1" {
  availability_domain = local.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "Web-Server-1"
  shape               = var.instance_shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.instance_flex_shape_memory
      ocpus         = var.instance_flex_shape_ocpus
    }
  }

  fault_domain = "FAULT-DOMAIN-1"

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  create_vnic_details {
    subnet_id = !var.use_existing_vcn ? oci_core_subnet.subnet_2[0].id : var.compute_subnet_id
    nsg_ids   = !var.use_existing_nsg ? [oci_core_network_security_group.WebSecurityGroup[0].id, oci_core_network_security_group.SSHSecurityGroup[0].id] : [var.compute_nsg_id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  timeouts {
    create = "60m"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Create Instacne Image

resource "oci_core_image" "flask_instance_image" {
  depends_on     = [null_resource.compute-script1]
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.compute_instance1.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Create Instacne Configuration

resource "oci_core_instance_configuration" "instance_configuration" {

  depends_on     = [oci_core_image.flask_instance_image, null_resource.compute-script1]
  compartment_id = var.compartment_ocid
  display_name   = "Instance_Configuration"
  instance_details {
    instance_type = "compute"
    launch_details {
      compartment_id = var.compartment_ocid
      shape          = var.instance_shape

      dynamic "shape_config" {
        for_each = local.is_flexible_node_shape ? [1] : []
        content {
          memory_in_gbs = var.instance_flex_shape_memory
          ocpus         = var.instance_flex_shape_ocpus
        }
      }

      source_details {
        source_type = "image"
        image_id    = oci_core_image.flask_instance_image.id
      }
      create_vnic_details {
        subnet_id = !var.use_existing_vcn ? oci_core_subnet.subnet_2[0].id : var.compute_subnet_id
        nsg_ids   = !var.use_existing_nsg ? [oci_core_network_security_group.WebSecurityGroup[0].id, oci_core_network_security_group.SSHSecurityGroup[0].id] : [var.compute_nsg_id]
      }
    }
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Create Instance Pool

resource "oci_core_instance_pool" "instance_pool" {
  compartment_id            = var.compartment_ocid
  instance_configuration_id = oci_core_instance_configuration.instance_configuration.id
  placement_configurations {
    availability_domain = local.availability_domain_name
    primary_subnet_id   = !var.use_existing_vcn ? oci_core_subnet.subnet_2[0].id : var.compute_subnet_id
  }
  size         = "2"
  display_name = "Instance_Pool"
  load_balancers {
    backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
    load_balancer_id = oci_load_balancer.lb1.id
    port             = "5000"
    vnic_selection   = "PrimaryVnic"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# Create Autoscaling Configuration

resource "oci_autoscaling_auto_scaling_configuration" "autoscaling_configuration" {
  auto_scaling_resources {

    id   = oci_core_instance_pool.instance_pool.id
    type = "instancePool"
  }
  compartment_id = var.compartment_ocid
  policies {
    display_name = "Threshold_AutoScaling_Configuration_Policies"
    capacity {
      initial = "2"
      max     = "4"
      min     = "2"
    }
    policy_type = "threshold"
    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "1"
      }
      display_name = "Threshold_AutoScaling_Configuration_Policies_ScaleOut_Rule"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value    = "80"
        }
      }
    }
    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "-1"
      }
      display_name = "Threshold_AutoScaling_Configuration_Policies_ScaleInRule"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value    = "20"
        }
      }
    }
  }
  cool_down_in_seconds = "300"
  display_name         = "Threshold_AutoScaling_Configuration"
  defined_tags         = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
