.PHONY: bootstrap image infra seed load-test destroy local-check local-clean

bootstrap:
	terraform -chdir=terraform/bootstrap init
	terraform -chdir=terraform/bootstrap apply

image:
	gcloud builds submit app/ --project=wideops-wordpress --region=europe-north2 --tag europe-north2-docker.pkg.dev/wideops-wordpress/wordpress/wordpress:v1

infra:
	terraform -chdir=terraform/main init
	terraform -chdir=terraform/main apply

seed:
	scripts/seed.sh

load-test:
	scripts/load-test.sh

destroy:
	terraform -chdir=terraform/main destroy

local-check: local-clean
	docker compose --file local/compose.yaml up --build --wait
	@printf '\nThe migrated site is running at http://localhost\nCheck it against local/checklist.md, then run: make local-clean\n'

local-clean:
	docker compose --file local/compose.yaml down --volumes --remove-orphans
