terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92""
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "api" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "apprunner_instance_role" {
  name               = "${var.service_name}-apprunner-instance-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_trust.json
}

data "aws_iam_policy_document" "apprunner_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "apprunner_logs" {
  role       = aws_iam_role.apprunner_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# App Runner service using the ECR image
resource "aws_apprunner_service" "api" {
  service_name = var.service_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_instance_role.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.api.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"

      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          PORT = "8080"
        }
      }
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu    = "1024" # 1 vCPU
    memory = "2048" # 2 GB
  }

  ping_check_configuration {
    path                = "/ping"
    interval            = 5
    timeout             = 2
  }

  tags = {
    Project = var.service_name
  }
}
