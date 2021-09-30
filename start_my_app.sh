#!/bin/bash

ProjectID="roi-takeoff-user62"
Region="us-central1"

if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=$ProjectID
fi
echo "ProjectID ="$GOOGLE_CLOUD_PROJECT

gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/todoapp

cd ./terraform
terraform init && terraform apply -auto-approve 
cd ..