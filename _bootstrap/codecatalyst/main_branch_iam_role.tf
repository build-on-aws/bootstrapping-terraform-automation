# Policy allowing the main branch in our repo to assume the role.
data "aws_iam_policy_document" "main_branch_assume_role_policy" {
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

# Role to allow the main branch to use this AWS account
resource "aws_iam_role" "main_branch" {
  name               = "Main-Branch-Infrastructure"
  assume_role_policy = data.aws_iam_policy_document.main_branch_assume_role_policy.json
}

# Allow role admin rights in the account to create all infra
resource "aws_iam_role_policy_attachment" "admin_policy_main_branch" {
  role       = aws_iam_role.main_branch.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
