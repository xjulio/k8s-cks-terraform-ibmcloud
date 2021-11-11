variable "vpc_region" {
  description = "VPC region"
  default     = "eu-gb"
}

variable "tags_for" {
  description = "tags for resource"
  default = [
    "owner: xjulio"
  ]
}
variable "resources_prefix" {
  description = "Prefix template."
  default     = "xjulio"
}

variable "profile" {
  description = "Profile cx2-2x4"
  default     = "cx2-2x4"
}

variable "instance_image_name" {
  description = "Replace below and get OS image name"
  default     = "ibm-ubuntu-18-04-5-minimal-amd64-1"
  #default    = "ibm-ubuntu-20-04-2-minimal-amd64-1"
  #default    = "ibm-ubuntu-20-04-minimal-amd64-2"

}

variable "vpc_zone_count" {
  default = 3
}

variable "vpc_cirdr" {
  default = "172.20.0.0/16"
}

variable "null" {
  default = ""
}
