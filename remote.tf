## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "bootstrap_template" {
  template = file("${path.module}/scripts/bootstrap.sh")

  vars = {
    ATP_tde_wallet_zip_file             = var.ATP_tde_wallet_zip_file
    oracle_instant_client_version       = var.oracle_instant_client_version
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

data "template_file" "db1_sh_template" {
  template = file("${path.module}//db_scripts/db1.sh")

  vars = {
    ATP_password                        = var.ATP_password
    ATP_alias                           = join("", [var.ATP_database_db_name, "_medium"])
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

data "template_file" "db1_sql_template" {
  template = file("${path.module}/db_scripts/db1.sql")

  vars = {
    ATP_password = var.ATP_password
  }
}

data "template_file" "app_py_template" {
  template = file("${path.module}/flask_dir/app.py")

  vars = {
    ATP_password                        = var.ATP_password
    ATP_alias                           = join("", [var.ATP_database_db_name, "_medium"])
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

data "template_file" "app_sh_template" {
  template = file("${path.module}/flask_dir/app.sh")

  vars = {
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

data "template_file" "sqlnet_ora_template" {
  template = file("${path.module}/flask_dir/sqlnet.ora")

  vars = {
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}


resource "null_resource" "compute-script1" {

  depends_on = [oci_core_instance.compute_instance1, module.oci-adb.adb_database, oci_core_network_security_group_security_rule.ATPSecurityEgressGroupRule, oci_core_network_security_group_security_rule.ATPSecurityIngressGroupRules]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "mkdir /home/opc/templates",
      "chown opc /home/opc/templates/",
      "mkdir /home/opc/static/",
      "chown opc /home/opc/static",
      "mkdir /home/opc/static/css/",
      "chown opc /home/opc/static/css/",
      "mkdir /home/opc/static/img",
    "chown opc /home/opc/static/img/"]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/flask_dir/static/css/"
    destination = "/home/opc/static/css"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/flask_dir/static/img/"
    destination = "/home/opc/static/img"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "${path.module}/flask_dir/templates/"
    destination = "/home/opc/templates"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.app_py_template.rendered
    destination = "/home/opc/app.py"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.app_sh_template.rendered
    destination = "/home/opc/app.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.sqlnet_ora_template.rendered
    destination = "/home/opc/sqlnet.ora"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.db1_sh_template.rendered
    destination = "/home/opc/db1.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.db1_sql_template.rendered
    destination = "/home/opc/db1.sql"
  }

  provisioner "local-exec" {
    command = "echo '${module.oci-adb.adb_database.adb_wallet_content}' >> ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.ATP_tde_wallet_zip_file}_encoded > ${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/home/opc/${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    content     = data.template_file.bootstrap_template.rendered
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "chmod +x /tmp/bootstrap.sh",
    "sudo /tmp/bootstrap.sh"]
  }

}

