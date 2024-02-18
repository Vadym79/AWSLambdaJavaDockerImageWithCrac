#!/bin/bash
aws dynamodb create-table \
    --table-name AWSLambdaSpringBoot32Java21DockerImageAndCRaCProductsTable \
    --attribute-definitions \
        AttributeName=PK,AttributeType=S \
    --key-schema \
        AttributeName=PK,KeyType=HASH \
     --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD \
    --endpoint-url http://localhost:8000