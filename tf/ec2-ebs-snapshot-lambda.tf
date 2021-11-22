
resource "aws_iam_role" "ec2_ebs_snapshot_lambda_role" {
  name               = "iam_role_ec2_ebs_snapshot_lambda_function"
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

resource "aws_iam_policy" "ec2_ebs_snapshot_policy" {

  name        = "iam_policy_lambda_ec2_ebs_snapshot_policy"
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
      "Action": [ 
        "ec2:CreateSnapshot",
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_ebs_snapshot_policy_attach" {
  role       = aws_iam_role.ec2_ebs_snapshot_lambda_role.name
  policy_arn = aws_iam_policy.ec2_ebs_snapshot_policy.arn
}

data "archive_file" "ec2_ebs_snapshot" {
  type        = "zip"
  source_file = "../lambdas/ec2-ebs-snapshot.py"
  output_path = "../lambdas/ec2-ebs-snapshot.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "ec2_ebs_snapshot" {
  filename         = "../lambdas/ec2-ebs-snapshot.zip"
  source_code_hash = data.archive_file.ec2_ebs_snapshot.output_base64sha256
  function_name    = "ec2-ebs-snapshot"
  timeout          = 120
  role             = aws_iam_role.ec2_ebs_snapshot_lambda_role.arn
  handler          = "ec2-ebs-snapshot.handler"
  runtime          = "python3.8"
  depends_on       = [aws_iam_role_policy_attachment.ec2_capture_metadata_policy_attach]
}
