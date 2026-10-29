terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "saa"
}

provider "aws" {
  alias   = "use1"
  region  = "us-east-1"
  profile = "saa"
}
