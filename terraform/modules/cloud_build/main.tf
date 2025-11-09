resource "google_cloudbuild_trigger" "trigger" {
  for_each = var.triggers

  project = var.project_id
  name    = each.key

  description     = try(each.value.description, null)
  filename        = try(each.value.filename, null)
  service_account = try(each.value.service_account, null)
  substitutions   = try(each.value.substitutions, null)
  included_files  = try(each.value.included_files, null)
  ignored_files   = try(each.value.ignored_files, null)

  github {
    owner = each.value.git_repo.owner
    name  = each.value.git_repo.name

    dynamic "push" {
      for_each = (try(each.value.git_repo.branch, null) != null || try(each.value.git_repo.tag, null) != null) ? [each.value.git_repo] : []
      content {
        branch = try(push.value.branch, null)
        tag    = try(push.value.tag, null)
      }
    }

    dynamic "pull_request" {
      for_each = try(each.value.git_repo.revision, null) == null ? [] : [each.value.git_repo]
      content {
        branch = pull_request.value.revision
      }
    }
  }

  dynamic "build" {
    for_each = each.value.build == null ? [] : [each.value.build]
    content {
      images = try(build.value.images, null)

      logs_bucket = try(build.value.logs_bucket, null)

      dynamic "options" {
        for_each = build.value.options == null ? [] : [build.value.options]
        content {
          logging = try(options.value.logging, null)
        }
      }

      dynamic "step" {
        for_each = try(build.value.steps, [])
        content {
          id         = try(step.value.id, null)
          name       = step.value.name
          entrypoint = try(step.value.entrypoint, null)
          args       = try(step.value.args, null)
          env        = try(step.value.env, null)
          dir        = try(step.value.dir, null)
          wait_for   = try(step.value.wait_for, null)
        }
      }

      timeout = try(build.value.timeout, null)
    }
  }
}

output "trigger_ids" {
  value = [for trigger in google_cloudbuild_trigger.trigger : trigger.trigger_id]
}
