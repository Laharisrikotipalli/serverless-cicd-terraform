.PHONY: dev staging prod destroy

AWS_REGION = us-east-1

dev:
	terraform -chdir=terraform/environments/dev init
	terraform -chdir=terraform/environments/dev apply -auto-approve

staging:
	terraform -chdir=terraform/environments/staging init
	terraform -chdir=terraform/environments/staging apply -auto-approve

prod:
	terraform -chdir=terraform/environments/prod init
	terraform -chdir=terraform/environments/prod apply -auto-approve

destroy:
	terraform -chdir=terraform/environments/dev destroy -auto-approve
	terraform -chdir=terraform/environments/staging destroy -auto-approve
	terraform -chdir=terraform/environments/prod destroy -auto-approve
