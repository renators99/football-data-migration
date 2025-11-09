# football-data-migration

Infraestructura como código para el pipeline de scrapers de datos de fútbol. La carpeta `terraform/` contiene todos los componentes necesarios para crear el dataset de BigQuery que recibe la información procesada, así como los artefactos de despliegue de Cloud Build y los servicios de Cloud Run que ejecutan los procesos.

## Estructura de Terraform

- `terraform/main.tf`: orquesta los módulos para BigQuery, Cloud Run y Cloud Build.
- `terraform/variables.tf`: variables de entrada para parametrizar el despliegue.
- `terraform/outputs.tf`: valores útiles tras aplicar la infraestructura.
- `terraform/modules/bigquery`: módulo que crea el dataset y las tablas de destino de los scrapers.
- `terraform/modules/cloud_run`: módulo que define los servicios de Cloud Run para ejecutar los procesos.
- `terraform/modules/cloud_build`: módulo que configura los triggers de Cloud Build responsables de construir y desplegar las imágenes de los scrapers (emplea repositorios conectados mediante la integración nativa de GitHub con Cloud Build).

## Variables principales

| Variable | Descripción |
| --- | --- |
| `project_id` | Proyecto de Google Cloud donde se crean los recursos. |
| `region` | Región por defecto para recursos regionales (Cloud Run). |
| `dataset_id` | Dataset de BigQuery que almacena la data final. |
| `dataset_location` | Ubicación del dataset (por ejemplo `US`). |
| `dataset_description` | Texto descriptivo del dataset. |
| `labels` | Mapa de etiquetas a aplicar en todos los recursos. |
| `tables` | Definición detallada de cada tabla que utilizan los scrapers. |
| `cloud_run_services` | Mapa de servicios de Cloud Run parametrizados por proceso. |
| `cloud_build_triggers` | Mapa de triggers de Cloud Build para compilar y desplegar contenedores. |

Consulta los archivos `terraform/variables.tf` y los módulos para conocer todas las opciones disponibles.

## Ejemplo de uso

Crea un archivo `terraform.tfvars` en la carpeta `terraform/` con una configuración similar a la siguiente:

```hcl
project_id        = "mi-proyecto"
region            = "us-central1"
dataset_id        = "football_scrapers"
dataset_location  = "US"
labels = {
  team = "data-eng"
  env  = "prod"
}

tables = {
  matches = {
    description   = "Resultados de los partidos procesados por los scrapers"
    friendly_name = "matches"
    schema = [
      { name = "match_id", type = "STRING", mode = "REQUIRED" },
      { name = "competition", type = "STRING" },
      { name = "season", type = "STRING" },
      { name = "scraped_at", type = "TIMESTAMP" }
    ]
    time_partitioning = {
      type  = "DAY"
      field = "scraped_at"
    }
  }

  players = {
    description = "Información de jugadores recolectada por los scrapers"
    schema = [
      { name = "player_id", type = "STRING", mode = "REQUIRED" },
      { name = "name", type = "STRING" },
      { name = "team", type = "STRING" },
      { name = "scraped_at", type = "TIMESTAMP" }
    ]
  }
}

cloud_run_services = {
  matches-loader = {
    image                 = "us-central1-docker.pkg.dev/mi-proyecto/football/matches-loader:latest"
    min_instance_count    = 0
    max_instance_count    = 3
    memory                = "512Mi"
    cpu                   = "1"
    timeout_seconds       = 600
    concurrency           = 4
    allow_unauthenticated = false
    env_vars = {
      DATASET_ID = "football_scrapers"
      TABLE_ID   = "matches"
    }
  }

  players-loader = {
    image              = "us-central1-docker.pkg.dev/mi-proyecto/football/players-loader:latest"
    service_account_email = "scrapers-runner@mi-proyecto.iam.gserviceaccount.com"
    annotations = {
      "run.googleapis.com/ingress" = "internal"
    }
    env_vars = {
      DATASET_ID = "football_scrapers"
      TABLE_ID   = "players"
    }
  }
}

cloud_build_triggers = {
  matches-loader = {
    description = "Build & Deploy del scraper de partidos"
    git_repo = {
      owner  = "mi-organizacion"
      name   = "football-scrapers"
      branch = "^main$"
    }
    filename = "cloudbuild/matches.yaml"
    substitutions = {
      _SERVICE_NAME = "matches-loader"
    }
  }

  players-loader = {
    git_repo = {
      owner  = "mi-organizacion"
      name   = "football-scrapers"
      branch = "^main$"
    }
    build = {
      steps = [
        {
          id   = "build"
          name = "gcr.io/cloud-builders/docker"
          args = ["build", "-t", "us-central1-docker.pkg.dev/mi-proyecto/football/players-loader:latest", "."]
        },
        {
          id   = "push"
          name = "gcr.io/cloud-builders/docker"
          args = ["push", "us-central1-docker.pkg.dev/mi-proyecto/football/players-loader:latest"]
        }
      ]
      images = [
        "us-central1-docker.pkg.dev/mi-proyecto/football/players-loader:latest"
      ]
    }
  }
}
```

## Comandos básicos

Desde la carpeta `terraform/` ejecuta:

```bash
terraform init
terraform plan
terraform apply
```

Asegúrate de tener las credenciales de Google Cloud configuradas (`gcloud auth application-default login`) o mediante variables de entorno como `GOOGLE_APPLICATION_CREDENTIALS` antes de aplicar los cambios.
