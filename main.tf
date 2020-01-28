data "aws_caller_identity" "current" {
}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # A map with the region is used for clarity, but only the account ID is needed
  elb_account_ids = [
    for key in keys(var.elb_logging_regions) : "arn:aws:iam::${var.elb_logging_regions[key]}:root"
  ]

}

resource "aws_s3_bucket" "this" {
  bucket = "${local.account_id}-${var.region}-${var.bucket_suffix}"
  acl    = "log-delivery-write"
  tags   = var.tags

  lifecycle_rule {
    id      = "expire"
    enabled = true

    noncurrent_version_expiration {
      days = 90
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
    enabled = true
  }

}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.this]
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
