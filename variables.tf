

variable "bucket_suffix" {
  default     = "elblogging"
  description = "Suffix to apply to bucket name"
  type        = string
}

variable "elb_logging_regions" {
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
  description = "Map of regions and account IDs to allow ELB logging access to"
  type        = map(string)

}

variable "region" {
  description = "Region to create logging bucket in"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Mapping of any extra tags you want added to resources"
  type        = map(string)
}
