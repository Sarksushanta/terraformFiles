terraform {
  backend "s3" {
    bucket = "terraform-state-281019"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
