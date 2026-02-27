#!/bin/bash
set -e

REGION="us-east-1"
ECR_REGISTRY="322095785990.dkr.ecr.us-east-1.amazonaws.com"
ECR_REPO="bia"
CLUSTER="cluster-bia"
SERVICE="service-bia"
TASK_FAMILY="task-def-bia"
IMAGE_TAG="${ECR_REGISTRY}/${ECR_REPO}:latest"

echo "=== Deploy Simple - Projeto BIA ==="
echo "Image: ${IMAGE_TAG}"
echo ""

echo "[1/5] Login no ECR..."
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

echo "[2/5] Build da imagem..."
docker build -t ${ECR_REPO}:latest .

echo "[3/5] Tag da imagem..."
docker tag ${ECR_REPO}:latest ${IMAGE_TAG}

echo "[4/5] Push para ECR..."
docker push ${IMAGE_TAG}

echo "[5/5] Forçando novo deploy no ECS..."
aws ecs update-service \
    --cluster ${CLUSTER} \
    --service ${SERVICE} \
    --force-new-deployment \
    --region ${REGION} \
    --query 'service.serviceName' \
    --output text

echo "✓ Deploy completo!"
