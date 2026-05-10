output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = module.ec2.jenkins_public_ip
}

output "app_public_ip" {
  description = "Public IP of the Application EC2 instance"
  value       = module.ec2.app_public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker image pushes"
  value       = module.ecr.repository_url
}

output "jenkins_url" {
  description = "Jenkins UI URL"
  value       = "http://${module.ec2.jenkins_public_ip}:8080"
}

output "app_url" {
  description = "Application URL"
  value       = "http://${module.ec2.app_public_ip}:3000"
}
