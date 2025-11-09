variable "project_id" {
  description = "ID del proyecto donde se crean los triggers de Cloud Build."
  type        = string
}

variable "triggers" {
  description = "Mapa de triggers de Cloud Build."
  type = map(object({
    description    = optional(string)
    filename       = optional(string)
    git_repo = object({
      name     = string
      owner    = string
      uri      = optional(string)
      branch   = optional(string)
      tag      = optional(string)
      revision = optional(string)
    })
    substitutions  = optional(map(string))
    included_files = optional(list(string))
    ignored_files  = optional(list(string))
    service_account = optional(string)
    build = optional(object({
      images = optional(list(string))
      logs_bucket = optional(string)
      options = optional(object({
        logging = optional(string)
      }))
      steps = optional(list(object({
        id         = optional(string)
        name       = string
        entrypoint = optional(string)
        args       = optional(list(string))
        env        = optional(list(string))
        dir        = optional(string)
        wait_for   = optional(list(string))
      })))
      timeout = optional(string)
    }))
  }))
  default = {}
}
