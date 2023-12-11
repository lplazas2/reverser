locals {
  environment            = "prod"
  namespace              = "${local.environment}-${var.region}"
  cluster_name           = "${local.namespace}-cluster"
  network_name           = "${local.namespace}-net"
  subnet_name            = "${local.namespace}-sub"
  master_auth_subnetwork = "${local.namespace}-masternet"
  pods_range_name        = "${local.namespace}-podr"
  svc_range_name         = "${local.namespace}-svcr"
  subnet_names           = [for subnet_self_link in module.gcp-network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  project       = var.project_id
  repository_id = "${local.namespace}-registry"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "binding" {
  project    = google_artifact_registry_repository.my-repo.project
  location   = google_artifact_registry_repository.my-repo.location
  repository = google_artifact_registry_repository.my-repo.name
  role       = "roles/artifactregistry.reader"
  members = [
    "allUsers",
  ]
}

module "gke" {
  source                          = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-autopilot-public-cluster?ref=v29.0.0"
  project_id                      = var.project_id
  name                            = local.cluster_name
  regional                        = true
  region                          = var.region
  network                         = module.gcp-network.network_name
  subnetwork                      = local.subnet_names[index(module.gcp-network.subnets_names, local.subnet_name)]
  ip_range_pods                   = local.pods_range_name
  ip_range_services               = local.svc_range_name
  release_channel                 = "REGULAR"
  enable_vertical_pod_autoscaling = true
  network_tags                    = [local.cluster_name]
  deletion_protection             = false
}
