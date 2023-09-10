#!/usr/bin bash

#aws iot describe-endpoint
export DEPLOYMENT_BUCKET=mangdang2023

export DOCKER=ros-humble-greengrass-demo

export IOT_ENDPOINT=`aws iot describe-endpoint | grep amazon | cut -d: -f 2 | sed 's/\"//g'` 
export YOUR_PRIVATE_ECR_IMAGE=`aws ecr describe-repositories | grep repositoryUri | grep ${DOCKER} | cut -d: -f 2 | 
sed 's/\"//g' | sed 's/\,//g' | tr -d  ' '`
#cd ~/environment/mini-pupper-aws
export ECR_IMAGE=${YOUR_PRIVATE_ECR_IMAGE}":latest"
echo $ECR_IMAGE
export RECIPE_CONFIG_FILE=greengrass/recipe.yaml

##### no need to change anything below
aws s3 cp greengrass/docker-compose.yaml s3://${DEPLOYMENT_BUCKET}/artifacts/docker-compose.yaml
#aws s3 sync robot_ws/src/mini_pupper_ros/mini_pupper_dance/routines s3://${DEPLOYMENT_BUCKET}/artifacts/routines
IOT_CONFIG_FILE=greengrass/aws_iot_params.yaml
cat ${IOT_CONFIG_FILE}.template | sed -e "s/IOT_ENDPOINT_PLACEHOLDER/${IOT_ENDPOINT}/g" > ${IOT_CONFIG_FILE}

aws s3 cp greengrass/aws_iot_params.yaml s3://${DEPLOYMENT_BUCKET}/artifacts/aws_iot_params.yaml
cat ${RECIPE_CONFIG_FILE}.template | sed -e "s#S3_BUCKET_PLACEHOLDER#${DEPLOYMENT_BUCKET}#g"  -e  "s#YOUR_PRIVATE_ECR_IMAGE#${ECR_IMAGE// /}#g"  > ${RECIPE_CONFIG_FILE}
aws greengrassv2 create-component-version     --inline-recipe fileb://${RECIPE_CONFIG_FILE}

