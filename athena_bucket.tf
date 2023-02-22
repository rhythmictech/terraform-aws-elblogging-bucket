
##########################################
# stores results from athena queries
##########################################

#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "athena_results" {
  count = var.create_athena_query ? 1 : 0

  bucket        = "${local.bucket_name}-athena-results"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_acl" "athena_results" {
  count = var.create_athena_query ? 1 : 0

  bucket = aws_s3_bucket.athena_results[0].id
  acl    = "private"
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  count = var.create_athena_query ? 1 : 0

  bucket = aws_s3_bucket.athena_results[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "athena_results" {
  count = var.create_athena_query ? 1 : 0

  bucket = aws_s3_bucket.athena_results[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  count = var.create_athena_query ? 1 : 0

  bucket = aws_s3_bucket.athena_results[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "athena_results" {
  count = var.create_athena_query ? 1 : 0

  bucket = aws_s3_bucket.athena_results[0].id

  versioning_configuration {
    status = "Enabled"
  }
}
