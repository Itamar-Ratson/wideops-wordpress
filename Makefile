PROJECT_ID := $(shell awk -F'"' '/^project_id/{print $$2}' terraform/project.tfvars)
REGION     := $(shell awk -F'"' '/^region/{print $$2}' terraform/project.tfvars)
IMAGE      := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/wordpress/wordpress:v1

.PHONY: bootstrap check-region image local-check local-clean

bootstrap: ## Enable APIs, verify the region, then create the image repository
	terraform -chdir=terraform/bootstrap init
	terraform -chdir=terraform/bootstrap apply -var-file=../project.tfvars
	gcloud artifacts repositories describe wordpress --project=$(PROJECT_ID) --location=$(REGION) --format='value(name,format)'

check-region: ## Verify compute, database, and repository availability
	scripts/check-region.sh

image: ## Build and push the immutable WordPress image with Cloud Build
	gcloud builds submit app/ --project=$(PROJECT_ID) --tag $(IMAGE) --region=$(REGION)
	gcloud artifacts docker images list $(REGION)-docker.pkg.dev/$(PROJECT_ID)/wordpress --project=$(PROJECT_ID) --include-tags --filter='tags:v1' --format='table(package,tags,createTime)'

local-check: local-clean
	docker compose up --build --wait
	@printf '\nThe migrated site is running at http://localhost\n'
	@printf 'Check it against scripts/local-check.md, then run: make local-clean\n'

local-clean:
	docker compose down --volumes --remove-orphans
