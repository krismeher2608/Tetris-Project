terraform {
  backend "s3" {
    bucket         = var.bucket_name
    key            = "my-terraform-environment/main"
    region         = "us-east-2"
    dynamodb_table = var.dynamodb_table
  }
}