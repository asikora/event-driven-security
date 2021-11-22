resource "aws_iam_role" "iam_for_sfn" {
  name = "step_function_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy_invoke_lambda" {
  name = "step_function_invoke_lambdas"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": [
                "${aws_lambda_function.sg_revoke_rule.arn}",
                "${aws_lambda_function.ec2_capture_metadata.arn}",
                "${aws_lambda_function.ec2_ebs_snapshot.arn}",
                "${aws_lambda_function.ec2_enable_protection.arn}",
                "${aws_lambda_function.ec2_isolate.arn}",
                "${aws_lambda_function.tag_resource.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_invoke_lambda" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = aws_iam_policy.policy_invoke_lambda.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "remediation-state-machine"
  role_arn = aws_iam_role.iam_for_sfn.arn

  definition = templatefile("../remediation_workflow.json", {
    ec2-capture-metadata-arn  = aws_lambda_function.ec2_capture_metadata.arn,
    ec2-ebs-snapshot-arn      = aws_lambda_function.ec2_ebs_snapshot.arn,
    ec2-enable-protection-arn = aws_lambda_function.ec2_enable_protection.arn,
    ec2-isolate-arn           = aws_lambda_function.ec2_isolate.arn,
    sg-revoke-rule-arn        = aws_lambda_function.sg_revoke_rule.arn,
    tag-resource-arn          = aws_lambda_function.tag_resource.arn
  })

}
