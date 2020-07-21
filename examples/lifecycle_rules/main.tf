
module "example" {
  source = "../.."

  bucket_name = "app-elb-access-logs"

  lifecycle_rules = [
    {
      id                            = "expire_prod"
      enabled                       = true
      prefix                        = "prodelb"
      expiration                    = 730
      noncurrent_version_expiration = 730
    },
    {
      id                            = "expire_dev"
      enabled                       = true
      prefix                        = "develb"
      expiration                    = 30
      noncurrent_version_expiration = 1
  }]
}
