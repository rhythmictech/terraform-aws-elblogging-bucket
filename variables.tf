
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

variable "elb_logging_regions" {
  description = "Map of regions and account IDs to allow ELB logging access to"
  type        = map(string)

  default = {
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    ca-central-1   = "985666609251"
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    eu-west-2      = "652711504416"
    eu-west-3      = "009996457667"
    eu-north-1     = "897822967062"
    ap-east-1      = "754344448648"
    ap-northeast-1 = "582318560864"
    ap-northeast-2 = "600734575887"
    ap-northeast-3 = "383597477331"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    ap-south-1     = "718504428378"
    me-south-1     = "076674570225"
    sa-east-1      = "507241528517"
  }
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

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}

variable "versioning_enabled" {
  default     = true
  description = "Whether or not to use versioning on the bucket. This can be useful for audit purposes since objects in a logging bucket should not be updated."
  type        = bool
}
