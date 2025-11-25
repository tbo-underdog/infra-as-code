output "ecr_repository_url" {
  description = "URL of the ECR repository to push the image to"
  value       = aws_ecr_repository.api.repository_url
}

output "apprunner_service_url" {
  description = "Public URL of the App Runner service"
  value       = aws_apprunner_service.api.service_url
}