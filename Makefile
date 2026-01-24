AWS_REGION = us-east-1

.PHONY: dev staging prod destroy-dev destroy-staging destroy-prod

# ------------------------
# DEV
# ------------------------
dev:
	terraform -chdir=terraform/environments/dev init
	terraform -chdir=terraform/environments/dev apply -auto-approve

destroy-dev:
	terraform -chdir=terraform/environments/dev destroy -auto-approve

# ------------------------
# STAGING
# ------------------------
staging:
	terraform -chdir=terraform/environments/staging init
	terraform -chdir=terraform/environments/staging apply -auto-approve

destroy-staging:
	terraform -chdir=terraform/environments/staging destroy -auto-approve

# ------------------------
# PROD (Blue/Green)
# ------------------------
prod:
	terraform -chdir=terraform/environments/prod init
	terraform -chdir=terraform/environments/prod apply -auto-approve

destroy-prod:
	terraform -chdir=terraform/environments/prod destroy -auto-approve