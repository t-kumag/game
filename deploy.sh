#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 [develop|staging|production] [rails|worker]"
  exit 1
fi

ENV=$1
TARGET=$2

if [ "${ENV}" = "develop" ]; then
  echo ENV: ${ENV}
  PREFIX=dev
elif [ "${ENV}" = "staging" ]; then
  echo ENV: ${ENV}
  PREFIX=stg
#elif [ "${ENV}" = "production" ]; then
#  echo ENV: ${ENV}
#  PREFIX=prod
else
  echo "Usage: $0 [develop|staging|production] [rails|worker]"
  exit 1
fi

if [ "${TARGET}" = "rails" ]; then
  CLUSTER=${PREFIX}-osidori-cluster
  SERVICE=${PREFIX}-osdr-fargate
elif [ "${TARGET}" = "worker" ]; then
  CLUSTER=${PREFIX}-osidori-cluster
  SERVICE=${PREFIX}-osdr-fargate-sidekiq
else
  echo "Usage: $0 [develop|staging|production] [rails|worker]"
  exit 1
fi
echo Target: ${TARGET}

# Update Fargate Service
aws ecs update-service --service ${SERVICE} --force-new-deployment --cluster ${CLUSTER}
