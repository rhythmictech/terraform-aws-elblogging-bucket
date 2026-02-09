data "aws_caller_identity" "current" {
}

data "aws_partition" "current" {
}

data "aws_region" "current" {
}

data "aws_elb_service_account" "principal" {
}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = var.bucket_name == null ? "${local.account_id}-${local.region}-${var.bucket_suffix}" : var.bucket_name
  partition   = data.aws_partition.current.partition
  region      = data.aws_region.current.name
}

#trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  tags   = var.tags

  dynamic "lifecycle_rule" {
    iterator = rule
    for_each = var.lifecycle_rules

    content {
      id      = rule.value.id
      enabled = rule.value.enabled
      prefix  = lookup(rule.value, "prefix", null)

      expiration {
        days = rule.value.expiration
      }

      noncurrent_version_expiration {
        days = rule.value.noncurrent_version_expiration
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }

  lifecycle {
    ignore_changes = [versioning_configuration[0].mfa_delete]
  }
}

#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  elb_source_accounts = (
    length(var.source_organizations) > 0 ? ["*"] : (
      contains(var.source_accounts, "self") > 0
      ? sort(concat(setsubtract(var.source_accounts, ["self"]), [local.account_id]))
      : sort(var.source_accounts)
    )
  )
  alb_source_arns = [for a in local.elb_source_accounts : "arn:aws:elasticloadbalancing:*:${a}:loadbalancer/*"]
  nlb_source_arns = [for a in local.elb_source_accounts : "arn:aws:logs:*:${a}:*"]
}

data "aws_iam_policy_document" "this" {

  dynamic "statement" {
    for_each = var.use_legacy_elb_policy ? [true] : []
    content {
      sid       = "AllowElbLogging"
      actions   = ["s3:PutObject"]
      effect    = "Allow"
      resources = ["arn:${local.partition}:s3:::${aws_s3_bucket.this.bucket}/*"]

      principals {
        type        = "AWS"
        identifiers = [data.aws_elb_service_account.principal.arn]
      }
    }
  }

  dynamic "statement" {
    for_each = var.use_legacy_elb_policy ? [] : [true]
    content {
      sid       = "AllowAlbLogging"
      actions   = ["s3:PutObject"]
      effect    = "Allow"
      resources = ["arn:${local.partition}:s3:::${aws_s3_bucket.this.bucket}/*"]
      principals {
        type        = "Service"
        identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
      }
      dynamic "condition" {
        for_each = length(local.alb_source_arns) > 0 ? [true] : []
        content {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = local.alb_source_arns
        }
      }
      dynamic "condition" {
        for_each = length(var.source_organizations) > 0 ? [true] : []
        content {
          test     = "StringEquals"
          variable = "aws:SourceOrgId"
          values   = var.source_organizations
        }
      }
    }
  }
  statement {
    sid       = "AllowNlbLogging"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${aws_s3_bucket.this.bucket}/*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    dynamic "condition" {
      for_each = length(local.nlb_source_arns) > 0 ? [true] : []
      content {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = local.nlb_source_arns
      }
    }
    dynamic "condition" {
      for_each = length(var.source_organizations) > 0 ? [true] : []
      content {
        test     = "StringEquals"
        variable = "aws:ResourceOrgID"
        values   = var.source_organizations
      }
    }

  }

  statement {
    sid       = "AllowNlbLoggingAclAccess"
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    effect    = "Allow"
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    dynamic "condition" {
      for_each = length(local.nlb_source_arns) > 0 ? [true] : []
      content {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = local.nlb_source_arns
      }
    }
    dynamic "condition" {
      for_each = length(var.source_organizations) > 0 ? [true] : []
      content {
        test     = "StringEquals"
        variable = "aws:ResourceOrgID"
        values   = var.source_organizations
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_logging" "this" {
  count = var.s3_access_logging_bucket == null ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.s3_access_logging_bucket
  target_prefix = var.s3_access_logging_prefix
}
