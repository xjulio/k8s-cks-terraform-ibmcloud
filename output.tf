output "vpc" {
  value = ibm_is_vpc.vsi_vpc.id
}

output "subnet_ids" {
  value = ibm_is_subnet.subnet.*.id
}

output "vsi_status" {
  value = ibm_is_instance.instance.*.status
}

output "vsi_1" {
  value = [ibm_is_instance.instance[0].id, ibm_is_instance.instance[0].primary_network_interface[0].primary_ipv4_address, ibm_is_instance.instance[0].primary_network_interface[0].id]
}

output "vsi_2" {
  value = [ibm_is_instance.instance[1].id, ibm_is_instance.instance[1].primary_network_interface[0].primary_ipv4_address, ibm_is_instance.instance[1].primary_network_interface[0].id]
}

output "fip1" {
  value = [ibm_is_floating_ip.fip_vsi[0].address, ibm_is_floating_ip.fip_vsi[0].target]
}

output "fip2" {
  value = [ibm_is_floating_ip.fip_vsi[1].address, ibm_is_floating_ip.fip_vsi[1].target]
}

output "ssh_file_name" {
  value = local.ssh_file_name
}
