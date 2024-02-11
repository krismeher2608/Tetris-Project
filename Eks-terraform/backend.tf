terraform {
  backend "s3" {
    bucket = "remote-backend-s3-krishnameher" # Replace with your actual S3 bucket name
    key    = "EKS/terraform.tfstate"
    region = "us-east-1"
  }
}
