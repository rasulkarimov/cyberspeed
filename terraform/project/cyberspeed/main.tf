module vpc {
  source = "../../modules/vpc"
  region = var.region
  cidrblock  = var.cidrblock
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
}

# module eks {
#   source = "../../modules/eks"
#   cluster_version  = var.cluster_version
#   cluster_name = var.cluster_name
#   depends_on = [ module.vpc ]
# }
