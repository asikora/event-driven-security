
resource "random_uuid" "name" {
}
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "evidence" {
  bucket = "evidence-bucket-${random_uuid.name.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.evidence.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
