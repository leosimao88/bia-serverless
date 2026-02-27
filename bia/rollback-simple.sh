#!/bin/bash
set -e

REGION="us-east-1"
CLUSTER="cluster-bia"
SERVICE="service-bia"
TASK_FAMILY="task-def-bia"
ECR_REPO="bia"

if [ -z "$1" ] || [ "$1" = "list" ]; then
    echo "=== Rollback Simple - Projeto BIA ==="
    echo ""
    echo "Uso: $0 <commit_hash>"
    echo ""
    echo "Últimas 10 versões disponíveis:"
    aws ecs list-task-definitions \
        --family-prefix ${TASK_FAMILY} \
        --region ${REGION} \
        --max-results 10 \
        --sort DESC \
        --query 'taskDefinitionArns[]' \
        --output text | tr '\t' '\n' | while read arn; do
            revision=$(echo $arn | sed 's/.*://')
            taskdef=$(aws ecs describe-task-definition --task-definition $arn --region ${REGION})
            tag=$(echo "$taskdef" | jq -r '.taskDefinition.containerDefinitions[0].image' | awk -F: '{print $NF}')
            created=$(echo "$taskdef" | jq -r '.taskDefinition.registeredAt' | cut -d'T' -f1)
            echo "Revisão: $revision | Tag: $tag | Criada: $created"
        done
    exit 0
fi

COMMIT_HASH=$1

echo "=== Rollback Simple - Projeto BIA ==="
echo "Buscando task definition com hash: ${COMMIT_HASH}"
echo ""

TASK_DEF_ARN=$(aws ecs list-task-definitions \
    --family-prefix ${TASK_FAMILY} \
    --region ${REGION} \
    --sort DESC \
    --query 'taskDefinitionArns[]' \
    --output text | tr '\t' '\n' | while read arn; do
        image=$(aws ecs describe-task-definition --task-definition $arn --region ${REGION} --query 'taskDefinition.containerDefinitions[0].image' --output text)
        if echo $image | grep -q ":${COMMIT_HASH}"; then
            echo $arn
            break
        fi
    done)

if [ -z "$TASK_DEF_ARN" ]; then
    echo "✗ Nenhuma task definition encontrada com o hash: ${COMMIT_HASH}"
    exit 1
fi

echo "Encontrada: ${TASK_DEF_ARN}"
echo ""

aws ecs update-service \
    --cluster ${CLUSTER} \
    --service ${SERVICE} \
    --task-definition ${TASK_DEF_ARN} \
    --region ${REGION} \
    --query 'service.taskDefinition' \
    --output text

echo ""
echo "✓ Rollback completo!"
