resource "aws_security_group" "deny_all" {
  name        = "deny_all"
  description = "Deny All trafic in and out"

  tags = {
    Name = "Deny ALl"
  }
}
