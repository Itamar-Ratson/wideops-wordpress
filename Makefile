.PHONY: local-check local-clean

local-check: local-clean
	docker compose up --build --wait
	@printf '\nThe migrated site is running at http://localhost\n'
	@printf 'Check it against scripts/local-check.md, then run: make local-clean\n'

local-clean:
	docker compose down --volumes --remove-orphans
