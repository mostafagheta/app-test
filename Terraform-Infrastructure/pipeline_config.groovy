/*
  JTE Global Configuration
  Library parameters live here (first config in the chain) so they are not
  stripped when the application pipeline_config.groovy is merged.
*/

@merge libraries {
    s3_versioning {
        s3_bucket = "atos-versioning-bucket"
        s3_version_file = "infra_version.json"
    }
    infra
    common
}

