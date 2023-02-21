output "s3_bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "s3_bucket_name" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.bucket
}

##########################################
# AWS Athena
##########################################

output "delete_athena_table_comand" {
  description = "The command to delete the athena table. This is given as an output as the destroy-time provisioner does not take arguments from external resources"
  value = var.create_athena_query ? templatefile("${path.module}/templates/delete_table.sh.tpl", {
    results_config    = "OutputLocation=s3://${aws_s3_bucket.this.bucket}/elblogging-athena-results"
    execution_context = "Database=${aws_athena_database.this[0].id}"
  }) : "Table not set to create"
}
