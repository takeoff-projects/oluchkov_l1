#!/bin/bash
cd terraform

terraform plan -destroy
terraform destroy  -auto-approve