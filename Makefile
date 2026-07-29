.PHONY: bootstrap image certificate infra seed destroy local-check local-clean

# Recursively expanded on purpose: the seed recipe reads Terraform outputs, and
# those must not be evaluated when an unrelated target runs.
TF_BOOTSTRAP = terraform -chdir=terraform/bootstrap
TF_MAIN = terraform -chdir=terraform/main

bootstrap:
	$(TF_BOOTSTRAP) init
	$(TF_BOOTSTRAP) apply

image:
	gcloud builds submit app/ \
	  --project=wideops-wordpress \
	  --region=europe-north2 \
	  --tag europe-north2-docker.pkg.dev/wideops-wordpress/wordpress/wordpress:v1

certificate:
	scripts/create-certificate.sh \
	  $$($(TF_BOOTSTRAP) output -raw project_id)

infra:
	$(TF_MAIN) init
	$(TF_MAIN) apply

# Cloud SQL reads both SQL files from Cloud Storage itself, so this needs no
# network path to the private instance. The second import applies the shared
# rewrite with the load balancer's stable HTTPS address.
seed:
	gcloud sql import sql \
	  $$($(TF_MAIN) output -raw sql_instance_name) \
	  $$($(TF_MAIN) output -raw database_dump_uri) \
	  --project=$$($(TF_MAIN) output -raw project_id) \
	  --database=wordpress \
	  --quiet
	scripts/rewrite-cloud-urls.sh \
	  $$($(TF_MAIN) output -raw project_id) \
	  $$($(TF_MAIN) output -raw sql_instance_name) \
	  gs://$$($(TF_MAIN) output -raw project_id)-assets \
	  $$($(TF_MAIN) output -raw load_balancer_ip)

destroy:
	$(TF_MAIN) destroy

local-check: local-clean
	docker compose up --build --wait
	@printf '\nThe migrated site is running at http://localhost\n'
	@printf 'Check it against scripts/local-check.md, then run: make local-clean\n'

local-clean:
	docker compose down --volumes --remove-orphans
