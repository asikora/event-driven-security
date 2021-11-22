
resource "aws_iam_role" "ec2_isolate_lambda_role" {
  name               = "iam_role_ec2_isolate_lambda_function"
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

resource "aws_iam_policy" "ec2_isolate_policy" {

  name        = "iam_policy_lambda_ec2_isolate_policy"
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
      "Action": "ec2:ModifyInstanceAttribute",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_isolate_policy_attach" {
  role       = aws_iam_role.ec2_isolate_lambda_role.name
  policy_arn = aws_iam_policy.ec2_isolate_policy.arn
}

data "archive_file" "ec2_isolate" {
  type        = "zip"
  source_file = "../lambdas/ec2-isolate.py"
  output_path = "../lambdas/ec2-isolate.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "ec2_isolate" {
  filename         = "../lambdas/ec2-isolate.zip"
  source_code_hash = data.archive_file.ec2_isolate.output_base64sha256
  function_name    = "ec2-isolate"
  role             = aws_iam_role.ec2_isolate_lambda_role.arn
  handler          = "ec2-isolate.handler"
  runtime          = "python3.8"
  depends_on       = [aws_iam_role_policy_attachment.ec2_capture_metadata_policy_attach]
  environment {
    variables = {
      SG_DENYALL = aws_security_group.deny_all.id
    }
  }
}
