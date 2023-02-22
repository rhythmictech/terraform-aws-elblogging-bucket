
resource "aws_athena_database" "this" {
  count = var.create_athena_query ? 1 : 0

  name    = "elb_logs"
  bucket  = aws_s3_bucket.this.bucket
  comment = "Database for ELB logs in bucket ${aws_s3_bucket.this.bucket}"

  encryption_configuration {
    encryption_option = "SSE_S3"
  }
}

resource "aws_athena_workgroup" "this" {
  count = var.create_athena_query ? 1 : 0

  name        = "elb_logs"
  description = "For ELB logs in bucket ${aws_s3_bucket.this.bucket}"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results[0].bucket}/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "null_resource" "create_table" {
  count = var.create_athena_query ? 1 : 0

  triggers = {
    athena_database = aws_athena_database.this[0].id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = templatefile("${path.module}/templates/create_table.sh.tpl", {
      results_config    = "OutputLocation=s3://${aws_s3_bucket.this.bucket}/elblogging-athena-results"
      execution_context = "Database=${aws_athena_database.this[0].id}"
      query_string = templatefile("${path.module}/templates/create_table.sql.tpl", {
        bucket     = aws_s3_bucket.this.bucket
        account_id = local.account_id
        region     = local.region
      })
    })
  }
}
