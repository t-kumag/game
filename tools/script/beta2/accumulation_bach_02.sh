#!/bin/bash

CLUSTER=arn:aws:ecs:ap-northeast-1:318279949697:cluster/osdr-dev-beta2-api
TASK=arn:aws:ecs:ap-northeast-1:318279949697:task-definition/osdr-dev-beta2-acmm:4
NET_CONFIG='awsvpcConfiguration={subnets=[subnet-0b2893ae0756ea356],securityGroups=[sg-00ad2a1f97ff4ae43],assignPublicIp=DISABLED}'
aws ecs run-task \
    --cluster ${CLUSTER} \
    --task-definition ${TASK} \
--launch-type FARGATE \
--network-configuration ${NET_CONFIG}
