#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

echo "=== [1/6] System update ==="
yum update -y

echo "=== [2/6] Install Java ==="
amazon-linux-extras enable java-openjdk11
yum install -y java-11-openjdk

echo "=== [3/6] Install Jenkins ==="
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins
systemctl enable jenkins
systemctl start jenkins

echo "=== [4/6] Install Docker ==="
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker
usermod -aG docker jenkins
usermod -aG docker ec2-user

echo "=== [5/6] Install AWS CLI v2 ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

echo "=== [6/6] Write environment config ==="
cat > /etc/jenkins-env.sh <<EOF
export AWS_REGION=${aws_region}
export ECR_REPOSITORY_URL=${ecr_repository_url}
EOF

systemctl restart jenkins

echo "=== Bootstrap complete ==="
