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

  logging = var.s3_access_logging_bucket == null ? [] : [{
    bucket = var.s3_access_logging_bucket
    prefix = var.s3_access_logging_prefix
  }]
}

#tfsec:ignore:AWS002
resource "aws_s3_bucket" "this" {
  bucket = "${local.account_id}-${local.region}-${var.bucket_suffix}"
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

  dynamic "logging" {
    iterator = log
    for_each = local.logging

    content {
      target_bucket = log.value.bucket
      target_prefix = lookup(log.value, "prefix", null)
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_id
        sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      }
    }
  }

  versioning {
    enabled = var.versioning_enabled
  }

  # this cannot be configured programatically via TF, so just ignore it if someone
  # turned it on administratively.
  lifecycle {
    ignore_changes = [versioning[0].mfa_delete]
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

  # this isn't really dependent on the public access block but there can be
  # race conditions when creating bucket policies simultaneously
  depends_on = [aws_s3_bucket_public_access_block.this]
}
