data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = var.bucket_name == null ? "${local.account_id}-${local.region}-${var.bucket_suffix}" : var.bucket_name
  region      = data.aws_region.current.name

  # A map with the region is used for clarity, but only the account ID is needed
  elb_account_ids = [
    for key in keys(var.elb_logging_regions) : "arn:aws:iam::${var.elb_logging_regions[key]}:root"
  ]

  logging = var.s3_access_logging_bucket == null ? [] : [{
    bucket = var.s3_access_logging_bucket
    prefix = var.s3_access_logging_prefix
  }]
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.account_id}-${local.region}-${var.bucket_suffix}"
  acl    = "log-delivery-write"
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
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled    = var.versioning_enabled
    mfa_delete = var.mfa_delete_enabled
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
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = local.elb_account_ids
    }

    resources = ["arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"]

  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json

  # this isn't really dependent on the public access block but there can be
  # race conditions when creating bucket policies simultaneously
  depends_on = [aws_s3_bucket_public_access_block.this]
}
