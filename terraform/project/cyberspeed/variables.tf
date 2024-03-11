variable "cidrblock" {
  type = string
  description = "If this is present, IPAM will not automatically generate the CIDR for you."
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "cluster_name" {
  type = string
  description = "The name of the cluster_name."
}

variable "cluster_version" {
  type = string
  description = "The version of the k8s cluster."
}