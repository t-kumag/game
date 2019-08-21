#!/bin/bash

CLUSTER=arn:aws:ecs:ap-northeast-1:318279949697:cluster/prod-osidori-cluster
TASK=arn:aws:ecs:ap-northeast-1:318279949697:task-definition/prod-osidori-acmm-task:3
NET_CONFIG='awsvpcConfiguration={subnets=[subnet-0216b936b4d379cc5,subnet-0b3e7a5b1047bde78,subnet-0d0ff10ddfeaa0583],securityGroups=[sg-015df9dad3d2224e0],assignPublicIp=DISABLED}'

aws ecs run-task \
    --cluster ${CLUSTER} \
    --task-definition ${TASK} \
--launch-type FARGATE \
--network-configuration ${NET_CONFIG}
