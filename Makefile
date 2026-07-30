.PHONY: bootstrap image infra seed load-test destroy local-check local-clean

# Recursively expanded on purpose: the seed recipe reads Terraform outputs, and
# those must not be evaluated when an unrelated target runs.
TF_BOOTSTRAP = terraform -chdir=terraform/bootstrap
TF_MAIN = terraform -chdir=terraform/main

# Defaults live in the load-test script itself; these only forward an override
# such as make load-test LOAD_DURATION=900 through to it.
export LOAD_DURATION LOAD_CONCURRENCY LOAD_SAMPLE_INTERVAL LOAD_SETTLE_TIMEOUT

bootstrap:
	$(TF_BOOTSTRAP) init
	$(TF_BOOTSTRAP) apply

image:
	gcloud builds submit app/ \
	  --project=wideops-wordpress \
	  --region=europe-north2 \
	  --tag europe-north2-docker.pkg.dev/wideops-wordpress/wordpress/wordpress:v1

infra:
	$(TF_MAIN) init
	$(TF_MAIN) apply

# Supplied media is synced under its browser-visible path. Cloud SQL then reads
# both SQL files from private Cloud Storage itself, so that needs no network path
# to the private instance. The second import applies the shared rewrite with the
# load balancer's stable HTTPS address.
seed:
	gcloud storage rsync --recursive \
	  app/wp-content/uploads \
	  $$($(TF_MAIN) output -raw uploads_uri) \
	  --project=$$($(TF_MAIN) output -raw project_id)
	gcloud sql import sql \
	  $$($(TF_MAIN) output -raw sql_instance_name) \
	  $$($(TF_MAIN) output -raw database_dump_uri) \
	  --project=$$($(TF_MAIN) output -raw project_id) \
	  --database=wordpress \
	  --quiet
	scripts/rewrite-cloud-urls.sh \
	  $$($(TF_MAIN) output -raw project_id) \
	  $$($(TF_MAIN) output -raw sql_instance_name) \
	  $$($(TF_MAIN) output -raw assets_uri) \
	  $$($(TF_MAIN) output -raw load_balancer_ip)

load-test:
	scripts/load-test.sh \
	  "https://$$($(TF_MAIN) output -raw load_balancer_ip)" \
	  "$$($(TF_MAIN) output -raw project_id)" \
	  "$$($(TF_MAIN) output -raw region)" \
	  "$$($(TF_MAIN) output -raw instance_group_name)"

destroy:
	$(TF_MAIN) destroy

local-check: local-clean
	docker compose up --build --wait
	@printf '\nThe migrated site is running at http://localhost\n'
	@printf 'Check it against scripts/local-check.md, then run: make local-clean\n'

local-clean:
	docker compose down --volumes --remove-orphans
