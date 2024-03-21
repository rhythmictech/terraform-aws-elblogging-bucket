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

#trivy:ignore:avd-aws-0089
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

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
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

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "AllowElbLogging"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${aws_s3_bucket.this.bucket}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.principal.arn]
    }
  }

  statement {
    sid       = "AllowNlbLogging"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${aws_s3_bucket.this.bucket}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowNlbLoggingAclAccess"
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
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
