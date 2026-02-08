
variable "bucket_name" {
  default     = null
  description = "Name to apply to bucket (use `bucket_name` or `bucket_suffix`)"
  type        = string
}

variable "bucket_suffix" {
  default     = "elblogging"
  description = "Suffix to apply to the bucket (use `bucket_name` or `bucket_suffix`). When using `bucket_suffix`, the bucket name will be `[ACCOUNT_ID]-[REGION]-s3logging-[BUCKET_SUFFIX]."
  type        = string
}

variable "create_athena_query" {
  default     = false
  description = "Create an Athena table for querying ALB logs. Uses the aws cli"
  type        = bool
}

variable "lifecycle_rules" {
  default     = []
  description = "lifecycle rules to apply to the bucket"

  type = list(object(
    {
      id                            = string
      enabled                       = bool
      prefix                        = string
      expiration                    = number
      noncurrent_version_expiration = number
  }))
}

variable "s3_access_logging_bucket" {
  default     = null
  description = "Optional target for S3 access logging"
  type        = string
}

variable "s3_access_logging_prefix" {
  default     = null
  description = "Optional target prefix for S3 access logging (only used if `s3_access_logging_bucket` is set)"
  type        = string
}

variable "source_accounts" {
  default     = []
  description = "List of AWS account IDs to restrict log delivery to. Defaults to caller account."
  type        = list(string)
}

variable "source_organizations" {
  default     = []
  description = "List of AWS Organization IDs to restrict log delivery to. Overrides `source_accounts`."
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}

variable "use_legacy_elb_policy" {
  default     = false
  description = "Use the legacy ELB policy statement from pre-2022."
  type        = bool
}

variable "versioning_enabled" {
  default     = true
  description = "Whether or not to use versioning on the bucket. This can be useful for audit purposes since objects in a logging bucket should not be updated."
  type        = bool
}
