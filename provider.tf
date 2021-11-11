provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.vpc_region
  ibmcloud_timeout = 300
}
