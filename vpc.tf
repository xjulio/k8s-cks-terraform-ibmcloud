# random number
resource "random_id" "name1" {
  byte_length = 2
}

# vpc
resource "ibm_is_vpc" "vsi_vpc" {
  name                      = "${var.resources_prefix}-vpc-${random_id.name1.hex}"
  address_prefix_management = "manual"
  tags                      = var.tags_for
}

resource "ibm_is_vpc_address_prefix" "subnet_prefix" {
  count = var.vpc_zone_count
  name  = "${var.resources_prefix}-${var.vpc_region}-${count.index + 1}"
  zone  = "${var.vpc_region}-${count.index % 3 + 1}"
  vpc   = ibm_is_vpc.vsi_vpc.id
  cidr  = cidrsubnet(var.vpc_cirdr, 8, count.index)
}

# subnets
resource "ibm_is_subnet" "subnet" {
  count           = var.vpc_zone_count
  name            = "${var.resources_prefix}-subnet-${var.vpc_region}-${count.index + 1}"
  vpc             = ibm_is_vpc.vsi_vpc.id
  zone            = "${var.vpc_region}-${count.index % 3 + 1}"
  ipv4_cidr_block = ibm_is_vpc_address_prefix.subnet_prefix[count.index].cidr
  depends_on      = [ibm_is_vpc_address_prefix.subnet_prefix]
}

# sg
resource "ibm_is_security_group" "security_group01" {
  name = "${var.resources_prefix}-sg-${var.vpc_region}-${random_id.name1.hex}"
  vpc  = ibm_is_vpc.vsi_vpc.id
}
resource "ibm_is_security_group_rule" "sg_icmp_rule" {
  group     = ibm_is_security_group.security_group01.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    code = 0
    type = 8
  }
}

# sg rules
resource "ibm_is_security_group_rule" "sg_tcp_rule1" {
  group     = ibm_is_security_group.security_group01.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

#k8s rules
resource "ibm_is_security_group_rule" "sg_tcp_k8s_api" {
  group     = ibm_is_security_group.security_group01.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 6443
    port_max = 6443
  }
}

resource "ibm_is_security_group_rule" "sg_tcp_k8s_etcd" {
  group     = ibm_is_security_group.security_group01.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 2379
    port_max = 2380
  }
}

resource "ibm_is_security_group_rule" "sg_tcp_k8s_kubelet" {
  group     = ibm_is_security_group.security_group01.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 1050
    port_max = 1050
  }
}

resource "ibm_is_security_group_rule" "sg_tcp_k8s_nodeports" {
  group     = ibm_is_security_group.security_group01.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "sg_outbound_all" {
  group     = ibm_is_security_group.security_group01.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
