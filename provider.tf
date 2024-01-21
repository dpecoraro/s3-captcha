provider "aws" {
  region                  = var.region

  skip_metadata_api_check = true
  skip_region_validation  = true
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-central-1"
}
