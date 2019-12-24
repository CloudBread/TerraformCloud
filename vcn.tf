resource "oci_core_vcn" "test_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "KafkaVcn"
  dns_label      = "kafkavcn"
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "KafkaInternetGateway"
  vcn_id         = "${oci_core_vcn.test_vcn.id}"
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = "${oci_core_vcn.test_vcn.default_route_table_id}"
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.test_internet_gateway.id}"
  }
}

resource "oci_core_subnet" "test_subnet" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  cidr_block          = "10.1.20.0/24"
  display_name        = "KafkaSubnet"
  dns_label           = "kafkasubnet"
  security_list_ids   = ["${oci_core_vcn.test_vcn.default_security_list_id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.test_vcn.id}"
  route_table_id      = "${oci_core_vcn.test_vcn.default_route_table_id}"
  dhcp_options_id     = "${oci_core_vcn.test_vcn.default_dhcp_options_id}"
}

# resource "oci_core_vcn" "vcn1" {
#   cidr_block     = "10.0.0.0/16"
#   dns_label      = "vcn1"
#   compartment_id = "${var.compartment_ocid}"
#   display_name   = "vcn1"
# }

# resource "oci_core_vcn" "vcn1" {
#   cidr_block     = "10.0.0.0/16"
#   dns_label      = "vcn1"
#   compartment_id = "${var.compartment_ocid}"
#   display_name   = "vcn1"
# }

# resource "oci_core_internet_gateway" "test_internet_gateway" {
#   compartment_id = "${var.compartment_ocid}"
#   display_name   = "testInternetGateway"
#   vcn_id         = "${oci_core_vcn.vcn1.id}"
# }

# resource "oci_core_default_route_table" "default_route_table" {
#   manage_default_resource_id = "${oci_core_vcn.vcn1.default_route_table_id}"
#   display_name               = "defaultRouteTable"

#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = "${oci_core_internet_gateway.test_internet_gateway.id}"
#   }
# }

# resource "oci_core_route_table" "route_table1" {
#   compartment_id = "${var.compartment_ocid}"
#   vcn_id         = "${oci_core_vcn.vcn1.id}"
#   display_name   = "routeTable1"

#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = "${oci_core_internet_gateway.test_internet_gateway.id}"
#   }
# }

# resource "oci_core_default_dhcp_options" "default_dhcp_options" {
#   manage_default_resource_id = "${oci_core_vcn.vcn1.default_dhcp_options_id}"
#   display_name               = "defaultDhcpOptions"

#   // required
#   options {
#     type        = "DomainNameServer"
#     server_type = "VcnLocalPlusInternet"
#   }

#   // optional
#   options {
#     type                = "SearchDomain"
#     search_domain_names = ["abc.com"]
#   }
# }

# resource "oci_core_dhcp_options" "dhcp_options1" {
#   compartment_id = "${var.compartment_ocid}"
#   vcn_id         = "${oci_core_vcn.vcn1.id}"
#   display_name   = "dhcpOptions1"

#   // required
#   options {
#     type        = "DomainNameServer"
#     server_type = "VcnLocalPlusInternet"
#   }

#   // optional
#   options {
#     type                = "SearchDomain"
#     search_domain_names = ["test123.com"]
#   }
# }

resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = "${oci_core_vcn.test_vcn.default_security_list_id}"
  display_name               = "defaultSecurityList"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  // allow outbound udp traffic on a port range
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "17"        // udp
    stateless   = true

    udp_options {
      min = 319
      max = 320
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }

  // allow inbound Kafka Connect REST API
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8083
      max = 8083
    }
  }

  // allow inbound KSQL Server REST API
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8088
      max = 8088
    }
  }

  // allow inbound REST Proxy
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8082
      max = 8082
    }
  }

  // allow inbound Schema Registry REST API
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 8081
      max = 8081
    }
  }

  // allow inbound JMX
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 1099
      max = 1099
    }
  }

  // allow inbound ZooKeeper
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 2181
      max = 2181
    }
  }

  // allow inbound ZooKeeper
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 2888
      max = 2888
    }
  }

  // allow inbound ZooKeeper
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 3888
      max = 3888
    }
  }

  // allow inbound Kafka Brokers
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 9092
      max = 9092
    }
  }

  // allow inbound Control Center
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 9091
      max = 9091
    }
  }
}
