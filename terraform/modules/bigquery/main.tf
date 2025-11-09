resource "google_bigquery_dataset" "scrapers" {
  dataset_id                  = var.dataset_id
  location                    = var.dataset_location
  description                 = var.dataset_description
  labels                      = var.labels
  delete_contents_on_destroy  = false
}

locals {
  table_schema = {
    for table_id, table in var.tables : table_id => jsonencode([
      for field in table.schema : {
        name        = field.name
        type        = field.type
        mode        = coalesce(field.mode, "NULLABLE")
        description = try(field.description, null)
      }
    ])
  }
}

resource "google_bigquery_table" "tables" {
  for_each = var.tables

  dataset_id                  = google_bigquery_dataset.scrapers.dataset_id
  table_id                    = each.key
  description                 = try(each.value.description, null)
  friendly_name               = try(each.value.friendly_name, null)
  expiration_time             = try(each.value.expiration_time, null)
  clustering                  = try(each.value.clustering, null)
  labels                      = var.labels
  schema                      = local.table_schema[each.key]

  dynamic "time_partitioning" {
    for_each = each.value.time_partitioning == null ? [] : [each.value.time_partitioning]
    content {
      type                     = time_partitioning.value.type
      field                    = try(time_partitioning.value.field, null)
      expiration_ms            = try(time_partitioning.value.expiration_ms, null)
      require_partition_filter = try(time_partitioning.value.require_partition_filter, null)
    }
  }

  dynamic "range_partitioning" {
    for_each = each.value.range_partitioning == null ? [] : [each.value.range_partitioning]
    content {
      field = range_partitioning.value.field

      range {
        start    = range_partitioning.value.range.start
        end      = range_partitioning.value.range.end
        interval = range_partitioning.value.range.interval
      }
    }
  }
}

output "dataset_id" {
  value = google_bigquery_dataset.scrapers.dataset_id
}

output "table_ids" {
  value = [for table in google_bigquery_table.tables : table.table_id]
}
