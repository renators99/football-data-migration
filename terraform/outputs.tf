output "dataset_id" {
  description = "ID del dataset de BigQuery creado."
  value       = module.bigquery.dataset_id
}

output "table_ids" {
  description = "IDs de las tablas de BigQuery creadas para los scrapers."
  value       = module.bigquery.table_ids
}

output "cloud_run_service_names" {
  description = "Servicios de Cloud Run desplegados."
  value       = module.cloud_run.service_names
}

output "cloud_build_trigger_ids" {
  description = "Triggers de Cloud Build configurados."
  value       = module.cloud_build.trigger_ids
}
