##   instances  ##
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_string" "randon_ssh_key_name" {
  length  = 16
  special = false
}

locals {
  ssh_file_name = "~/.ssh/${random_string.randon_ssh_key_name.result}.pem"
}

resource "local_file" "pem_file" {
  filename             = pathexpand(local.ssh_file_name)
  file_permission      = "400"
  directory_permission = "700"
  sensitive_content    = tls_private_key.pk.private_key_pem
}

resource "ibm_is_ssh_key" "linux_key" {
  name       = "${var.resources_prefix}-key-${var.vpc_region}-${random_id.name1.hex}"
  public_key = tls_private_key.pk.public_key_openssh
}

# image
data "ibm_is_image" "vsi_image" {
  name       = var.instance_image_name
  visibility = "public"
}

resource "ibm_is_instance" "instance" {
  count   = 2
  name    = "${var.resources_prefix}-vsi-${var.vpc_region}-${count.index + 1}-${random_id.name1.hex}"
  image   = data.ibm_is_image.vsi_image.id
  profile = var.profile
  vpc     = ibm_is_vpc.vsi_vpc.id
  primary_network_interface {
    subnet          = element(ibm_is_subnet.subnet.*.id, count.index)
    security_groups = [ibm_is_security_group.security_group01.id]
  }

  zone      = "${var.vpc_region}-${count.index + 1}"
  keys      = [ibm_is_ssh_key.linux_key.id]
  tags      = var.tags_for
  user_data = <<-EOF
                #!/bin/bash
                apt update -y                
                apt-get install -y git curl util-linux
                if grep "\-1\-" <<<"$HOSTNAME"; then
                    hostnamectl set-hostname cks-master --static --transient
                    export HOSTNAME=cks-master
                    curl -fsSL https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_master.sh -o /tmp/install_master.sh
                    chmod +x /tmp/install_master.sh
                    /tmp/install_master.sh
                    sleep 10s&
                else
                    hostnamectl set-hostname cks-worker --static --transient
                    export HOSTNAME=cks-worker
                    curl -fsSL https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_worker.sh -o /tmp/install_worker.sh
                    chmod +x /tmp/install_worker.sh
                    /tmp/install_worker.sh
                    sleep 10s&
                fi               
            EOF  
}

# attaching fip
resource "ibm_is_floating_ip" "fip_vsi" {
  count = 2
  name  = "${var.resources_prefix}-fip-${var.vpc_region}-${count.index + 1}-${random_id.name1.hex}"

  target = element(ibm_is_instance.instance.*.primary_network_interface.0.id, count.index)
}
