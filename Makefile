.PHONY: bootstrap image local-check local-clean

bootstrap:
	terraform -chdir=terraform/bootstrap init
	terraform -chdir=terraform/bootstrap apply

image:
	gcloud builds submit app/ \
	  --project=wideops-wordpress \
	  --region=europe-north2 \
	  --tag europe-north2-docker.pkg.dev/wideops-wordpress/wordpress/wordpress:v1

local-check: local-clean
	docker compose up --build --wait
	@printf '\nThe migrated site is running at http://localhost\n'
	@printf 'Check it against scripts/local-check.md, then run: make local-clean\n'

local-clean:
	docker compose down --volumes --remove-orphans
