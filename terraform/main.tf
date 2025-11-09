terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.84"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "bigquery" {
  source = "./modules/bigquery"

  dataset_id          = var.dataset_id
  dataset_location    = var.dataset_location
  dataset_description = var.dataset_description
  labels              = var.labels
  tables              = var.tables
}

module "cloud_run" {
  source = "./modules/cloud_run"

  project_id = var.project_id
  region     = var.region
  services   = var.cloud_run_services
}

module "cloud_build" {
  source = "./modules/cloud_build"

  project_id = var.project_id
  triggers   = var.cloud_build_triggers
}

