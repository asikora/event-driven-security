resource "aws_iam_role" "cloudwatch_stepfunction_role" {
  name = "cloudwatch_stepfunction_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_stepfunction_policy" {
  name = "cloudwatch_stepfunction_policy"
  role = aws_iam_role.cloudwatch_stepfunction_role.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "states:StartExecution",
            "Resource": "${aws_sfn_state_machine.sfn_state_machine.arn}"
        }
    ]
}
DOC
}

// Rules

resource "aws_cloudwatch_event_rule" "sg" {
  name        = "capture-ec2-change-sg-group"
  description = "Capture SG wide open"

  event_pattern = <<EOF
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "AuthorizeSecurityGroupIngress"
    ]
  }
}
EOF
}
resource "aws_cloudwatch_event_target" "stepfunction_sg_group" {
  rule     = aws_cloudwatch_event_rule.sg.name
  arn      = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn = aws_iam_role.cloudwatch_stepfunction_role.arn
}

resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "capture-guardduty-events"
  description = "Capture SG wide open"

  event_pattern = <<EOF
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"]
}
EOF
}

resource "aws_cloudwatch_event_target" "stepfunctio_gd" {
  rule     = aws_cloudwatch_event_rule.guardduty.name
  arn      = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn = aws_iam_role.cloudwatch_stepfunction_role.arn
}
