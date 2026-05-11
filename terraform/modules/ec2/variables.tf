variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "jenkins_sg_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "jenkins_instance_type" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "aws_region" {
  type = string
}
