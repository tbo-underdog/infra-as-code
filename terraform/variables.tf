variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "service_name" {
  description = "Name for the App Runner service"
  type        = string
  default     = "go-aws-iac-example"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "go-aws-iac-example"
}

variable "image_tag" {
  description = "Tag of the image to deploy (e.g. latest)"
  type        = string
  default     = "latest"
}
