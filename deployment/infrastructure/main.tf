terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}


resource "google_container_cluster" "default" {
  name     = var.cluster_name
  location = var.region

  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count = 1

  addons_config {
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "spot_node_pool_16_64" {
  name       = "spot-node-pool-16-64"
  location   = var.region
  cluster    = google_container_cluster.default.name

  node_config {
    spot = true
    machine_type = "n2d-standard-16" # 16vcpu/64gb mem
  }

  # Node pool settings like autoscaling, management, etc.
  autoscaling {
    min_node_count = 0
    max_node_count = 20
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}


resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig"
  file_permission = "0600"
  content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_ca_certificate = google_container_cluster.default.master_auth[0].cluster_ca_certificate
    cluster_endpoint       = google_container_cluster.default.endpoint
    access_token           = data.google_client_config.default.access_token
  })
}


data "google_client_config" "default" {
  depends_on = [google_container_cluster.default]
}


provider "helm" {
  kubernetes {
    host                   = google_container_cluster.default.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)
  }
}

resource "helm_release" "local_chart" {
  name       = "flamenco"
  chart      = "../chart"

  # Include additional settings, overrides, and configuration as needed
}
