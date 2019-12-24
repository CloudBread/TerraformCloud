variable "zookeeper_instance_shape" {
  type    = "list"
  default = ["VM.Standard2.1", "VM.Standard.E2.1", "VM.Standard.E2.1"]
}

variable "broker_instance_shape" {
  type    = "list"
  default = ["VM.Standard.E2.2", "VM.Standard.E2.2", "VM.Standard2.1"]
}

variable "compartment_ocid" {
  #MCD150 - MCD
  default = "ocid1.compartment.oc1..aaaaaaaauyxch7hglh4d5mbalk7orzovjtvidnpblcbgtooyj6qplgceyt2a"
}

variable "num_instances" {
  type = "map"

  default = {
    zookeeper = 3
    broker    = 3
    schema    = 1
    connect   = 1
    rest      = 1
    ksql      = 1
    control   = 1
  }
}

variable "instance_image_ocid" {
  type = "map"

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaoqj42sokaoh42l76wsyhn3k2beuntrh5maj3gmgmzeyr55zzrwwa"

    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"

    # Oracle linux 7.7 2019.11.12
    # See https://docs.cloud.oracle.com/iaas/images/image/501c6e22-4dc6-4e99-b045-cae47aae343f/
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaavwjewurl3nvcyq6bgpbrapk4wfwu6qz2ljlrj2yk3cfqexeq64na"
  }
}

# variable "db_size" {
#   default = "50" # size in GBs
# }

# variable "tag_namespace_description" {
#   default = "Just a test"
# }

# variable "tag_namespace_name" {
#   default = "testexamples-tag-namespace"
# }

resource "oci_core_instance" "zookeeper" {
  count               = "${var.num_instances["zookeeper"]}"
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "zookeeper_${count.index}"
  shape               = "${var.zookeeper_instance_shape[count.index]}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.test_subnet.id}"
    display_name     = "Primaryvnic"
    assign_public_ip = true
    hostname_label   = "zookeeper${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file("./userdata/bootstrap"))}"
  }
  freeform_tags = "${map("ZooKeeperSvr", "ZooKeeper${count.index}")}"
  timeouts {
    create = "60m"
  }
}

resource "oci_core_instance" "broker" {
  count               = "${var.num_instances["broker"]}"
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "broker_${count.index}"
  shape               = "${var.broker_instance_shape[count.index]}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.test_subnet.id}"
    display_name     = "Primaryvnic"
    assign_public_ip = true
    hostname_label   = "broker${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file("./userdata/bootstrap"))}"
  }

  freeform_tags = "${map("BrokerSvr", "Broker${count.index}")}"

  timeouts {
    create = "60m"
  }
}

# resource "oci_core_instance" "ksql" {
#   availability_domain = "${data.oci_identity_availability_domain.ad.name}"
#   compartment_id      = "${var.compartment_ocid}"
#   display_name        = "ksql_control_center"
#   shape               = "VM.Standard.E2.1.Micro"

#   create_vnic_details {
#     subnet_id        = "${oci_core_subnet.test_subnet.id}"
#     display_name     = "Primaryvnic"
#     assign_public_ip = true
#     hostname_label   = "ksql"
#   }

#   source_details {
#     source_type = "image"
#     source_id   = "${var.instance_image_ocid[var.region]}"
#   }

#   metadata = {
#     ssh_authorized_keys = "${var.ssh_public_key}"
#     user_data           = "${base64encode(file("./userdata/bootstrap"))}"
#   }

#   freeform_tags = "${map("Server", "ksql_control_center")}"

#   timeouts {
#     create = "60m"
#   }
# }

# resource "oci_core_instance" "rest" {
#   availability_domain = "${data.oci_identity_availability_domain.ad.name}"
#   compartment_id      = "${var.compartment_ocid}"
#   display_name        = "rest_connnect"
#   shape               = "VM.Standard.E2.1.Micro"

#   create_vnic_details {
#     subnet_id        = "${oci_core_subnet.test_subnet.id}"
#     display_name     = "Primaryvnic"
#     assign_public_ip = true
#     hostname_label   = "rest"
#   }

#   source_details {
#     source_type = "image"
#     source_id   = "${var.instance_image_ocid[var.region]}"
#   }

#   metadata = {
#     ssh_authorized_keys = "${var.ssh_public_key}"
#     user_data           = "${base64encode(file("./userdata/bootstrap"))}"
#   }

#   freeform_tags = "${map("Server", "rest_connect")}"

#   timeouts {
#     create = "60m"
#   }
# }

data "oci_identity_availability_domain" "ad" {
  compartment_id = "${var.tenancy_ocid}"
  ad_number      = 1
}


output "ZooKeeper_Address"{
    # count = "${num_instances["zookeeper"]}"
    value = "${oci_core_instance.zookeeper.*.public_ip}"

}

output "Broker_Address"{
    #count = "${num_instances["broker"]}"
    value = "${oci_core_instance.broker.*.public_ip}"

# }
# output "ksql_Address"{
#     value = "${oci_core_instance.ksql.public_ip}"

# }
# output "rest_Address"{
#     value = "${oci_core_instance.rest.public_ip}"

}