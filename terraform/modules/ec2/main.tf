data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── IAM Role ─────────────────────────────────────────────────────────────────
resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.project}-${var.environment}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# ── Granular ECR policy (replaces AmazonEC2ContainerRegistryFullAccess) ──────
# Scoped to only the permissions Jenkins and App EC2 actually need.
# GetAuthorizationToken must be on * (AWS requirement).
# All other actions are scoped to the specific repository.
resource "aws_iam_role_policy" "ecr_granular" {
  name = "${var.project}-${var.environment}-ecr-policy"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuthToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryAccess"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:*:repository/${var.project}-${var.environment}-app"
      }
    ]
  })
}

# ── CloudWatch Agent policy ───────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "cloudwatch_full" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ── Instance Profile ──────────────────────────────────────────────────────────
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# ── Jenkins EC2 ───────────────────────────────────────────────────────────────
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.jenkins_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.jenkins_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/templates/jenkins_userdata.sh.tpl", {
    aws_region         = var.aws_region
    ecr_repository_url = var.ecr_repository_url
  })

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins"
    Role        = "CI/CD"
    Project     = var.project
    Environment = var.environment
  }
}

# ── App EC2 ───────────────────────────────────────────────────────────────────
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.app_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/templates/app_userdata.sh.tpl", {
    aws_region = var.aws_region
  })

  tags = {
    Name        = "${var.project}-${var.environment}-app"
    Role        = "Application"
    Project     = var.project
    Environment = var.environment
  }
}

# ── CloudWatch Log Group ──────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "app" {
  name              = "/damolak/${var.environment}/app"
  retention_in_days = 7

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# ── CloudWatch CPU Alarm ──────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${var.project}-${var.environment}-app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when App EC2 CPU exceeds 80% for 4 minutes"

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
