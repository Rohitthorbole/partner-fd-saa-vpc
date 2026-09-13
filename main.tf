terraform {
  required_providers {
    aws = {
        source = "hasicorp/aws"
        version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-eat-1"
}

