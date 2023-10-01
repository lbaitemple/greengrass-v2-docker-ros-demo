#!/usr/bin bash

#aws iot describe-endpoint
export DEPLOYMENT_BUCKET=mangdang992023
export DOCKER=ros-humble-greengrass-demo


# no need to change anything below
export IOT_ENDPOINT=`aws iot describe-endpoint | grep amazon | cut -d: -f 2 | sed 's/\"//g'` 
export YOUR_PRIVATE_ECR_IMAGE=`aws ecr describe-repositories | grep repositoryUri | grep ${DOCKER} | cut -d: -f 2 | 
sed 's/\"//g' | sed 's/\,//g' | tr -d  ' '`
#cd ~/environment/mini-pupper-aws
export ECR_IMAGE=${YOUR_PRIVATE_ECR_IMAGE}":latest"
export DOCKER=${DOCKER}":latest"

export RECIPE_CONFIG_FILE=greengrass/recipe.yaml

##### no need to change anything below
sed '3,6d' greengrass/docker-compose.yaml > greengrass/docker-compose_nobuild.yaml
aws s3 cp greengrass/docker-compose_nobuild.yaml s3://${DEPLOYMENT_BUCKET}/artifacts/docker-compose_nobuild.yaml
#aws s3 sync robot_ws/src/mini_pupper_ros/mini_pupper_dance/routines s3://${DEPLOYMENT_BUCKET}/artifacts/routines
IOT_CONFIG_FILE=greengrass/aws_iot_params.yaml
cat ${IOT_CONFIG_FILE}.template | sed -e "s/IOT_ENDPOINT_PLACEHOLDER/${IOT_ENDPOINT}/g" > ${IOT_CONFIG_FILE}

aws s3 cp greengrass/aws_iot_params.yaml s3://${DEPLOYMENT_BUCKET}/artifacts/aws_iot_params.yaml
cat ${RECIPE_CONFIG_FILE}.template | sed -e "s#S3_BUCKET_PLACEHOLDER#${DEPLOYMENT_BUCKET}#g" -e "s#DOCKER_IMAGE#${DOCKER}#g" -e  "s#YOUR_PRIVATE_ECR_IMAGE#${ECR_IMAGE}#g"  > ${RECIPE_CONFIG_FILE}
aws greengrassv2 create-component-version     --inline-recipe fileb://${RECIPE_CONFIG_FILE}

