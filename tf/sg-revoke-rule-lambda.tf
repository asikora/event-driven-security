
resource "aws_iam_role" "sg_revoke_rule_lambda_role" {
  name               = "iam_role_sg_revoke_rule_lambda_function"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sg_revoke_rule_policy" {

  name        = "iam_policy_lambda_sg_revoke_rule_policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  #tfsec:ignore:aws-iam-no-policy-wildcards
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:RevokeSecurityGroupIngress",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sg_revoke_rule_policy_attach" {
  role       = aws_iam_role.sg_revoke_rule_lambda_role.name
  policy_arn = aws_iam_policy.sg_revoke_rule_policy.arn
}

data "archive_file" "sg_revoke_rule" {
  type        = "zip"
  source_file = "../lambdas/sg-revoke-rule.py"
  output_path = "../lambdas/sg-revoke-rule.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "sg_revoke_rule" {
  filename         = "../lambdas/sg-revoke-rule.zip"
  source_code_hash = data.archive_file.sg_revoke_rule.output_base64sha256
  function_name    = "sg-revoke-rule"
  role             = aws_iam_role.sg_revoke_rule_lambda_role.arn
  handler          = "sg-revoke-rule.handler"
  runtime          = "python3.8"
  depends_on       = [aws_iam_role_policy_attachment.sg_revoke_rule_policy_attach]
}
