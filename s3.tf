resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-281019"
  acl    = "private"

  tags = {
    Name = "Terraform state"
  }
}

