.DEFAULT_GOAL := help

.ONESHELL:
.SUFFIXES:

# Source make_shell_functions if not running under Jenkins
#ifeq ($(origin BUILD_URL), undefined)
#SHELL = /bin/bash --rcfile make_shell_functions -i
#else
SHELL = /bin/bash
#endif

# Make variables assigned with '=' are evaluated every use
WORKSPACE = $(shell if [ -f '.current_workspace' ]; then cat .current_workspace; fi)
OWNER ?= $(shell echo $$USER)

# Make variables assigned with ':=' are evaluated once and set
TERRAFORM_DEFAULT_OPTIONS := -input=false -lock=true
TERRAFORM_BACKEND_OPTIONS := -backend=true -backend-config="bucket=ps-dev-tf-state"
TERRAFORM_VARIABLE_OPTIONS := -var-file="common/common.tfvars.json" -var="workspace=$(WORKSPACE)" -var="owner=$(OWNER)" -var="credentials=$(GOOGLE_APPLICATION_CREDENTIALS)"

.PHONY: REQUIRE-ENV REQUIRE-DIR

require-env-%: REQUIRE-ENV
	@ if [ -z '${${*}}' ]; then echo 'Environment variable $* not set.' && exit 1; fi

require-dir-%: REQUIRE-DIR
	@ pushd examples >/dev/null; if [ ! -d ${${*}} ]; then echo 'Directory examples/$* not found.' && exit 1; fi; popd >/dev/null

.current_workspace:
	@ if [ ! -f '.current_workspace' ]; then cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z0-9' | fold -w 6 | head -n 1 | xargs printf "%s-%s" $${USER:-$$HOSTNAME} > .current_workspace; fi || true
	@ echo Using shell $(SHELL)
	@ echo Using WORKSPACE $(WORKSPACE)

## -- Terraform wrappers
## Terraform init examples/<subdir>
.PHONY: init-%
init-%: require-dir-% require-env-GOOGLE_APPLICATION_CREDENTIALS .current_workspace
	@ terraform init \
		$(TERRAFORM_VARIABLE_OPTIONS) \
		$(TERRAFORM_BACKEND_OPTIONS) \
		-input=false \
		-verify-plugins=true \
		"examples/$*"
	@ terraform workspace select $(WORKSPACE) || terraform workspace new $(WORKSPACE)

## Terraform plan examples/<subdir> and output .tfstate
.PHONY: plan-%
plan-%: init-% $(addprefix, "examples/$*", *.tf)
	@ terraform plan \
		$(TERRAFORM_DEFAULT_OPTIONS) \
	    $(TERRAFORM_VARIABLE_OPTIONS) \
		-input=false \
		-out="$*-$(WORKSPACE).tfstate" \
		"examples/$*"

## Terraform apply .tfstate output from plan examples/<subdir>
.PHONY: apply-%
apply-%: .current_workspace require-dir-% require-env-GOOGLE_APPLICATION_CREDENTIALS
	@ if [ ! -f "$*-$(WORKSPACE).tfstate" ]; then $(MAKE) plan-$*; fi
	@ terraform apply \
		$(TERRAFORM_DEFAULT_OPTIONS) \
		-auto-approve \
		-input=false \
		"$*-$(WORKSPACE).tfstate"

## Terraform destroy examples/<subdir>
.PHONY: destroy-%
destroy-%: .current_workspace require-dir-% require-env-GOOGLE_APPLICATION_CREDENTIALS
	@ if [ -f "$*-$(WORKSPACE).tfstate" ]; then rm "$*-$(WORKSPACE).tfstate"; fi
	@ terraform destroy \
		$(TERRAFORM_DEFAULT_OPTIONS) \
	    $(TERRAFORM_VARIABLE_OPTIONS) \
		-auto-approve \
		-input=false \
		"examples/$*"

## Check format of files under examples/<subdir>
.PHONY: check-%
check-%: .current_workspace require-dir-%
	@ terraform fmt -check -write=false -recursive -diff "examples/$*"

.PHONY: fmt-%
## Format (overwrite!) files under examples/<subdir>
fmt-%: .current_workspace require-dir-%
	@ terraform fmt -recursive "examples/$*"

.PHONY: graph-%
## Graph resources for examples/<subdir>
## With GraphViz installed, make graph-<example> | dot -Tsvg -o file.svg 
graph-%: .current_workspace require-dir-%
	@ terraform graph "examples/$*"

## -- Testing
## Run tests
.PHONY: test
test: require-env-GOOGLE_APPLICATION_CREDENTIALS
	@ /usr/bin/env bats test

## -- Cleanup
## Delete the current_workspace from remote backend
.PHONY: workspace-delete
workspace-delete: require-env-GOOGLE_APPLICATION_CREDENTIALS .current_workspace
# If the local cache is not present, must init again for backend connection
	@ echo $(WORKSPACE)
	@ terraform workspace select default >/dev/null || \
		terraform init $(TERRAFORM_BACKEND_OPTIONS) >/dev/null && \
		terraform workspace select default >/dev/null
	@ terraform workspace delete -lock=false -force $(WORKSPACE)
	@ rm .current_workspace

## -- Misc
## This help message
.PHONY: help
help: 
# See https://gist.github.com/prwhite/8168133
	@printf "Usage: make <target>\n\nTargets:\n";

	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9%]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					sub(/[%]/, "<example subdir>", helpCommand); \
					printf "\033[31m%-30s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.%]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					sub(/[%]/, "<example subdir>", helpCommand); \
					printf "\033[31m%-30s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^## --/) { \
				printf "\n%s\n", substr($$0, 4); \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                               "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                               "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)
	@ printf "\nExample subdirs:\n"
	@ (cd examples; find * -maxdepth 1 -type d | grep --color=auto '.*') # Piped to grep merely for the color
