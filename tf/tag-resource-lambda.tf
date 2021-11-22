
resource "aws_iam_role" "tag_resource_role" {
  name               = "iam_role_tag_resource_function"
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

resource "aws_iam_policy" "tag_resource_policy" {

  name        = "iam_policy_lambda_tag_resource_policy"
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
      "Action": "ec2:CreateTags",
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tag_resource_policy_attach" {
  role       = aws_iam_role.tag_resource_role.name
  policy_arn = aws_iam_policy.tag_resource_policy.arn
}

data "archive_file" "tag_resource" {
  type        = "zip"
  source_file = "../lambdas/tag-resource.py"
  output_path = "../lambdas/tag-resource.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "tag_resource" {
  filename         = "../lambdas/tag-resource.zip"
  source_code_hash = data.archive_file.ec2_enable_protection.output_base64sha256
  function_name    = "tag-resource"
  role             = aws_iam_role.tag_resource_role.arn
  handler          = "tag-resource.handler"
  runtime          = "python3.8"
  depends_on       = [aws_iam_role_policy_attachment.ec2_capture_metadata_policy_attach]
}
