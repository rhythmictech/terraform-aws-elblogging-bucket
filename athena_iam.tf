
##########################################
# minimal IAM policy to allow querying of elb logs with athena
##########################################

locals {
  athena_bucket_arn    = try(aws_s3_bucket.athena_results[0].arn, "arn:${local.partition}:s3:::bucket")
  athena_workgroup_arn = try(aws_athena_workgroup.this[0].arn, "arn:${local.partition}:athena:${local.region}:${local.account_id}:workgroup/workgroup")
}
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "athena" {
  statement {
    sid       = "AllowGetAthenaMetadata"
    resources = ["*"]
    actions = [
      "athena:GetDatabase",
      "athena:GetTableMetadata",
      "athena:ListDatabases",
      "athena:ListDataCatalogs",
      "athena:ListEngineVersions",
      "athena:ListTableMetadata",
      "athena:ListWorkGroups",
      "glue:GetDatabases",
      "glue:GetTables",
      "glue:GetTable"
    ]
  }

  statement {
    sid       = "AllowRunWorkgroup"
    resources = [local.athena_workgroup_arn]
    actions = [
      "athena:UpdatePreparedStatement",
      "athena:StopQueryExecution",
      "athena:StartQueryExecution",
      "athena:ListQueryExecutions",
      "athena:ListPreparedStatements",
      "athena:ListNamedQueries",
      "athena:GetWorkGroup",
      "athena:GetQueryResultsStream",
      "athena:GetQueryResults",
      "athena:GetQueryExecution",
      "athena:GetQueryRuntimeStatistics",
      "athena:GetPreparedStatement",
      "athena:GetNamedQuery",
      "athena:DeletePreparedStatement",
      "athena:DeleteNamedQuery",
      "athena:CreatePreparedStatement",
      "athena:CreateNamedQuery",
      "athena:BatchGetQueryExecution",
      "athena:BatchGetNamedQuery"
    ]
  }

  statement {
    sid = "AllowGetBucketMetadata"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      local.athena_bucket_arn,
      aws_s3_bucket.this.arn,
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:CalledVia"
      values   = ["athena.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowReadLogs"
    resources = ["${aws_s3_bucket.this.arn}/*"]
    actions = [
      "s3:Describe*",
      "s3:Get*",
      "s3:List*"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:CalledVia"
      values   = ["athena.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowWriteResults"
    resources = ["${local.athena_bucket_arn}/*"]
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:CalledVia"
      values   = ["athena.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "athena" {
  count = var.create_athena_query ? 1 : 0

  name_prefix = "athena_query_elb_logs"
  path        = "/"
  description = "Allows the user to query ELB logs with Athena"
  policy      = data.aws_iam_policy_document.athena.json
}
