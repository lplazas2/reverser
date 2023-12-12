provider "google" {
  project = "bamboo-copilot-407420"
  region  = "europe-west1"
  zone    = "europe-west1-a"
}

module "prod_gke_cluster" {
  // TODO should use a versioned module, ideally from a different repo
  source = "github.com/lplazas2/reverser//terraform/modules/gke_cluster"
}

//TODO remote state and lock
