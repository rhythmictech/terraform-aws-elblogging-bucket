terraform {
  required_version = ">= 0.13.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.8"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
  }
}
