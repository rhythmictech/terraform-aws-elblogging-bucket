# terraform-aws-elblogging-bucket
[![tflint](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

Create and manage a bucket suitable for access logging for ELBs.

## Usage
```
module "elblogging-bucket" {
  source        = "rhythmictech/elblogging-bucket/aws"

  bucket_suffix = "application"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | Name to apply to bucket (use `bucket_name` or `bucket_suffix`) | `string` | `null` | no |
| bucket\_suffix | Suffix to apply to the bucket (use `bucket_name` or `bucket_suffix`). When using `bucket_suffix`, the bucket name will be `[ACCOUNT_ID]-[REGION]-s3logging-[BUCKET_SUFFIX].` | `string` | `"elblogging"` | no |
| elb\_logging\_regions | Map of regions and account IDs to allow ELB logging access to | `map(string)` | <pre>{<br>  "ap-east-1": "754344448648",<br>  "ap-northeast-1": "582318560864",<br>  "ap-northeast-2": "600734575887",<br>  "ap-northeast-3": "383597477331",<br>  "ap-south-1": "718504428378",<br>  "ap-southeast-1": "114774131450",<br>  "ap-southeast-2": "783225319266",<br>  "ca-central-1": "985666609251",<br>  "eu-central-1": "054676820928",<br>  "eu-north-1": "897822967062",<br>  "eu-west-1": "156460612806",<br>  "eu-west-2": "652711504416",<br>  "eu-west-3": "009996457667",<br>  "me-south-1": "076674570225",<br>  "sa-east-1": "507241528517",<br>  "us-east-1": "127311923021",<br>  "us-east-2": "033677994240",<br>  "us-west-1": "027434742980",<br>  "us-west-2": "797873946194"<br>}</pre> | no |
| lifecycle\_rules | lifecycle rules to apply to the bucket | <pre>list(object(<br>    {<br>      id                            = string<br>      enabled                       = bool<br>      prefix                        = string<br>      expiration                    = number<br>      noncurrent_version_expiration = number<br>  }))</pre> | `[]` | no |
| s3\_access\_logging\_bucket | Optional target for S3 access logging | `string` | `null` | no |
| s3\_access\_logging\_prefix | Optional target prefix for S3 access logging (only used if `s3_access_logging_bucket` is set) | `string` | `null` | no |
| tags | Tags to add to supported resources | `map(string)` | `{}` | no |
| versioning\_enabled | Whether or not to use versioning on the bucket. This can be useful for audit purposes since objects in a logging bucket should not be updated. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_arn | The ARN of the bucket |
| s3\_bucket\_domain\_name | The domain name of the bucket |
| s3\_bucket\_name | The name of the bucket |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
