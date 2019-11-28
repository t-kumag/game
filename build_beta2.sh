#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 [beta2] [rails|worker|batch]"
  exit 1
fi

ENV=$1
TARGET=$2

if [ "${ENV}" = "beta2" ]; then
  echo ENV: ${ENV}
  ENV=latest
else
  echo "Usage: $0 [beta2] [rails|worker|batch]"
  exit 1
fi

if [ "${TARGET}" = "rails" ]; then
  REPOSITORY=osidori-api/dev-beta2
  DOCKER_FILE=rails.Dockerfile 
elif [ "${TARGET}" = "worker" ]; then
  REPOSITORY=osidori-api/dev-beta2-worker
  DOCKER_FILE=worker.Dockerfile 
elif [ "${TARGET}" = "batch" ]; then
  REPOSITORY=osidori/batch-acmm-beta2
  DOCKER_FILE=batch.Dockerfile 
else
  echo "Usage: $0 [beta2] [rails|worker|batch]"
  exit 1
fi
echo Target: ${TARGET} / ${REPOSITORY}

ECR=318279949697.dkr.ecr.ap-northeast-1.amazonaws.com/${REPOSITORY}

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
