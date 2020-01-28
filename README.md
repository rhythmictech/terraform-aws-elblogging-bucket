# terraform-aws-elblogging-bucket
[![](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/workflows/check/badge.svg)](https://github.com/rhythmictech/terraform-aws-elblogging-bucket/actions)

Create and manage a bucket suitable for access logging for ELBs.

## Usage
```
module "elblogging-bucket" {
  source        = "git::https://github.com/rhythmictech/terraform-aws-elblogging-bucket"
  region        = var.region
  bucket_suffix = "account"
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket\_suffix | Suffix to apply to bucket name | string | `"elblogging"` | no |
| elb\_logging\_regions | Map of regions and account IDs to allow ELB logging access to | map(string) | `{ "ap-east-1": "754344448648", "ap-northeast-1": "582318560864", "ap-northeast-2": "600734575887", "ap-northeast-3": "383597477331", "ap-south-1": "718504428378", "ap-southeast-1": "114774131450", "ap-southeast-2": "783225319266", "ca-central-1": "985666609251", "eu-central-1": "054676820928", "eu-north-1": "897822967062", "eu-west-1": "156460612806", "eu-west-2": "652711504416", "eu-west-3": "009996457667", "me-south-1": "076674570225", "sa-east-1": "507241528517", "us-east-1": "127311923021", "us-east-2": "033677994240", "us-west-1": "027434742980", "us-west-2": "797873946194" }` | no |
| region | Region to create logging bucket in | string | n/a | yes |
| tags | Mapping of any extra tags you want added to resources | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_arn | The ARN of the bucket |
| s3\_bucket\_name | The name of the bucket |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
