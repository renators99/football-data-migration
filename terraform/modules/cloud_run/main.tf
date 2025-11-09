locals {
  service_configs = {
    for name, config in var.services : name => merge(
      {
        location = coalesce(config.location, var.region)
      },
      config
    )
  }
}

resource "google_cloud_run_service" "service" {
  for_each = local.service_configs

  name     = each.key
  location = each.value.location

  template {
    metadata {
      annotations = merge(
        each.value.min_instance_count == null ? {} : { "autoscaling.knative.dev/minScale" = tostring(each.value.min_instance_count) },
        each.value.max_instance_count == null ? {} : { "autoscaling.knative.dev/maxScale" = tostring(each.value.max_instance_count) },
        try(each.value.annotations, {})
      )
    }

    spec {
      service_account_name = try(each.value.service_account_email, null)
      container_concurrency = try(each.value.concurrency, null)
      timeout_seconds       = try(each.value.timeout_seconds, null)

      containers {
        image = each.value.image

        dynamic "env" {
          for_each = try(each.value.env_vars, {})
          content {
            name  = env.key
            value = env.value
          }
        }

        resources {
          limits = merge(
            each.value.cpu == null ? {} : { "cpu" = each.value.cpu },
            each.value.memory == null ? {} : { "memory" = each.value.memory }
          )
        }
      }

      dynamic "vpc_access" {
        for_each = each.value.vpc_connector == null ? [] : [each.value]
        content {
          connector = vpc_access.value.vpc_connector
          egress    = try(vpc_access.value.vpc_egress, null)
        }
      }
    }
  }

  dynamic "traffic" {
    for_each = length(coalesce(each.value.traffic, [])) == 0 ? [
      {
        percent         = 100
        latest_revision = true
        revision_name   = null
      }
    ] : each.value.traffic
    content {
      percent         = traffic.value.percent
      latest_revision = try(traffic.value.latest_revision, null)
      revision_name   = try(traffic.value.revision_name, null)
    }
  }

  ingress = try(each.value.ingress, null)
}

resource "google_cloud_run_service_iam_member" "invoker" {
  for_each = {
    for name, config in local.service_configs : name => config
    if try(config.allow_unauthenticated, false)
  }

  location = google_cloud_run_service.service[each.key].location
  service  = google_cloud_run_service.service[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_names" {
  value = [for service in google_cloud_run_service.service : service.name]
}
