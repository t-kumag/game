#!/bin/bash

ENV=latest
REPOSITORY=osidori/batch-acmm-beta2
ECR=318279949697.dkr.ecr.ap-northeast-1.amazonaws.com/${REPOSITORY}
DOCKER_FILE=batch.Dockerfile # Dockerfile for accumulation:move_money

DATE_TAG=$(date +${ENV}-v%Y%m%d_%H%M%S)

# login ecr
$(aws ecr get-login --no-include-email --region ap-northeast-1)

# set previous tag to current image
MANIFEST=$(aws ecr batch-get-image \
  --repository-name ${REPOSITORY} \
  --image-ids imageTag=${ENV} \
  --query images[].imageManifest \
  --output text)

aws ecr put-image \
  --repository-name ${REPOSITORY} \
  --image-tag previous-${ENV} \
  --image-manifest "$MANIFEST"

# build and push image
docker build -t ${REPOSITORY}:${ENV} -f ${DOCKER_FILE} .
docker tag ${REPOSITORY}:${ENV} ${ECR}:${ENV}
docker tag ${REPOSITORY}:${ENV} ${ECR}:${DATE_TAG}
docker push ${ECR}:${ENV}
docker push ${ECR}:${DATE_TAG}
