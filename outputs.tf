output "s3_bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_name" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.bucket
}
