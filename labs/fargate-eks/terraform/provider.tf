terraform {
  backend "s3" {
    bucket = "tf-roi"
    key    = "terraform.tfstate"
    region = "eu-west-1"

  }
}

provider "aws" {
  version = ">= 2.28.1"
  region  = "eu-west-1"
}
