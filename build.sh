#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 [develop|staging|production] [rails|worker|batch|stocklog|appstore|googleplay]"
  exit 1
fi

ENV=$1
TARGET=$2

if [ "${ENV}" = "develop" ]; then
  echo ENV: ${ENV}
elif [ "${ENV}" = "staging" ]; then
  echo ENV: ${ENV}
elif [ "${ENV}" = "production" ]; then
  echo ENV: ${ENV}
else
  echo "Usage: $0 [develop|staging|production] [rails|worker|batch|stocklog|appstore|googleplay]"
  exit 1
fi

if [ "${TARGET}" = "rails" ]; then
  REPOSITORY=osidori/osidori-api
  DOCKER_FILE=rails.Dockerfile
elif [ "${TARGET}" = "worker" ]; then
  REPOSITORY=osidori/osidori-sidekiq
  DOCKER_FILE=worker.Dockerfile
elif [ "${TARGET}" = "batch" ]; then
  REPOSITORY=osidori/batch-acmm
  DOCKER_FILE=batch.Dockerfile
elif [ "${TARGET}" = "stocklog" ]; then
  REPOSITORY=osidori/batch-stocklog
  DOCKER_FILE=batcn_stock_log.Dockerfile
elif [ "${TARGET}" = "appstore" ]; then
  REPOSITORY=osidori/batch-appstore
  DOCKER_FILE=batch_app_store.Dockerfile
elif [ "${TARGET}" = "googleplay" ]; then
  REPOSITORY=osidori/batch-googleplay
  DOCKER_FILE=batch_google_play.Dockerfile
else
  echo "Usage: $0 [develop|staging|production] [rails|worker|batch|stocklog|appstore|googleplay]"
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
docker build --no-cache -t ${REPOSITORY}:${ENV} -f ${DOCKER_FILE} .
docker tag ${REPOSITORY}:${ENV} ${ECR}:${ENV}
docker tag ${REPOSITORY}:${ENV} ${ECR}:${DATE_TAG}
docker push ${ECR}:${ENV}
docker push ${ECR}:${DATE_TAG}
