variable "project_id" {
  description = "ID del proyecto de Google Cloud donde se desplegará la infraestructura."
  type        = string
}

variable "region" {
  description = "Región por defecto para los recursos regionales."
  type        = string
  default     = "us-central1"
}

variable "dataset_id" {
  description = "Identificador del dataset de BigQuery que almacena los datos de los scrapers."
  type        = string
}

variable "dataset_location" {
  description = "Ubicación del dataset de BigQuery."
  type        = string
  default     = "US"
}

variable "dataset_description" {
  description = "Descripción del dataset de BigQuery."
  type        = string
  default     = "Dataset para almacenar los resultados de los scrapers de fútbol."
}

variable "labels" {
  description = "Etiquetas comunes para los recursos creados."
  type        = map(string)
  default     = {}
}

variable "tables" {
  description = "Configuración de las tablas de destino para los scrapers."
  type = map(object({
    description    = optional(string)
    friendly_name  = optional(string)
    expiration_time = optional(number)
    clustering     = optional(list(string))
    time_partitioning = optional(object({
      type                     = string
      field                    = optional(string)
      expiration_ms            = optional(number)
      require_partition_filter = optional(bool)
    }))
    range_partitioning = optional(object({
      field = string
      range = object({
        start    = number
        end      = number
        interval = number
      })
    }))
    schema = list(object({
      name        = string
      type        = string
      mode        = optional(string, "NULLABLE")
      description = optional(string)
    }))
  }))
  default = {}
}

variable "cloud_run_services" {
  description = "Definición de los servicios de Cloud Run que ejecutan los procesos ETL."
  type = map(object({
    location               = optional(string)
    image                  = string
    max_instance_count     = optional(number)
    min_instance_count     = optional(number)
    cpu                    = optional(string)
    memory                 = optional(string)
    concurrency            = optional(number)
    service_account_email  = optional(string)
    env_vars               = optional(map(string))
    annotations            = optional(map(string))
    ingress                = optional(string)
    allow_unauthenticated  = optional(bool, false)
    vpc_connector          = optional(string)
    vpc_egress             = optional(string)
    timeout_seconds        = optional(number)
    traffic = optional(list(object({
      percent        = number
      latest_revision = optional(bool)
      revision_name  = optional(string)
    })))
  }))
  default = {}
}

variable "cloud_build_triggers" {
  description = "Triggers de Cloud Build para construir y desplegar los scrapers."
  type = map(object({
    description   = optional(string)
    filename      = optional(string)
    git_repo      = object({
      name     = string
      owner    = string
      uri      = optional(string)
      branch   = optional(string)
      tag      = optional(string)
      revision = optional(string)
    })
    substitutions = optional(map(string))
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
