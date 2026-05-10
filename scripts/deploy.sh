#!/bin/bash
set -euo pipefail

echo "=== [1/4] Logging into ECR ==="
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${ECR_REPOSITORY_URL}

echo "=== [2/4] Pulling new image: ${IMAGE_TAG} ==="
docker pull ${ECR_REPOSITORY_URL}:${IMAGE_TAG}

echo "=== [3/4] Stopping existing container ==="
docker stop damolak-app || true
docker rm damolak-app || true

echo "=== [4/4] Starting new container ==="
docker run -d \
  --name damolak-app \
  --restart unless-stopped \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e APP_VERSION=${IMAGE_TAG} \
  -v /var/log/app:/var/log/app \
  ${ECR_REPOSITORY_URL}:${IMAGE_TAG}

echo "=== Deployment complete. Container status: ==="
docker ps | grep damolak-app
