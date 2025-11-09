variable "dataset_id" {
  description = "ID del dataset de BigQuery."
  type        = string
}

variable "dataset_location" {
  description = "Ubicación del dataset de BigQuery."
  type        = string
}

variable "dataset_description" {
  description = "Descripción del dataset."
  type        = string
  default     = null
}

variable "labels" {
  description = "Etiquetas aplicadas al dataset y sus tablas."
  type        = map(string)
  default     = {}
}

variable "tables" {
  description = "Esquema de las tablas del dataset."
  type = map(object({
    description       = optional(string)
    friendly_name     = optional(string)
    expiration_time   = optional(number)
    clustering        = optional(list(string))
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
