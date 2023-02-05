# Policy allowing the PR branches in our repo to assume the role. 
data "aws_iam_policy_document" "pr_branch_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "codecatalyst.amazonaws.com",
        "codecatalyst-runner.amazonaws.com"
      ]
    }
  }
}

# Role to allow PR branch to use this AWS account
resource "aws_iam_role" "pr_branch" {
  name               = "PR-Branch-Infrastructure"
  assume_role_policy = data.aws_iam_policy_document.pr_branch_assume_role_policy.json
}

# Allow PR Branch read-only access in the account to run `plan`
resource "aws_iam_role_policy_attachment" "readonly_policy_pr_branch" {
  role       = aws_iam_role.pr_branch.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Additional policy allowing read and write access to the DynamoDB table
# to create locks when `plan` is run.
data "aws_iam_policy_document" "pr_branch_lock_table_access" {
  statement {
    sid    = "DynamoDBIndexAndStreamAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetShardIterator",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:ListStreams"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}/index/*",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}/stream/*"
    ]
  }

  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}"
    ]
  }

  statement {
    sid    = "DynamoDBDescribeLimitsAccess"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeLimits"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}/index/*"
    ]
  }

  statement {
    sid    = "KMSS3Acess"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    # NB: While we allow "*" access to all KMS resources, we limit it to only the
    # "alias/s3" default key with the `StringLike` condition.
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:RequestAlias"
      values = [
        "alias/s3"
      ]
    }
  }
}

# Create a policy that allows reading and writing to the lock table
resource "aws_iam_policy" "lock_table_policy_pr_branch" {
  name   = "pr_branch_lock_table_access_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.pr_branch_lock_table_access.json
}

# Allow PR branch read and write to the lock table for `plan`
resource "aws_iam_role_policy_attachment" "lock_table_policy_pr_branch" {
  role       = aws_iam_role.pr_branch.name
  policy_arn = aws_iam_policy.lock_table_policy_pr_branch.arn
}
