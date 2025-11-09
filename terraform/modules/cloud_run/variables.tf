variable "project_id" {
  description = "ID del proyecto donde se crean los servicios de Cloud Run."
  type        = string
}

variable "region" {
  description = "Región por defecto para los servicios de Cloud Run."
  type        = string
}

variable "services" {
  description = "Servicios de Cloud Run que se deben desplegar."
  type = map(object({
    location              = optional(string)
    image                 = string
    max_instance_count    = optional(number)
    min_instance_count    = optional(number)
    cpu                   = optional(string)
    memory                = optional(string)
    concurrency           = optional(number)
    service_account_email = optional(string)
    env_vars              = optional(map(string))
    annotations           = optional(map(string))
    ingress               = optional(string)
    allow_unauthenticated = optional(bool, false)
    vpc_connector         = optional(string)
    vpc_egress            = optional(string)
    timeout_seconds       = optional(number)
    traffic = optional(list(object({
      percent         = number
      latest_revision = optional(bool)
      revision_name   = optional(string)
    })))
  }))
  default = {}
}
