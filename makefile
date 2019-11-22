#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME := dl-course
VENV = $(PROJECT_DIR)/.venv
PIP = $(VENV)/bin/pip
PYTHON ?= python3.7
VIRTUALENV = $(PYTHON) -m venv
CONDAROOT = $(HOME)/anaconda3
SHELL=/bin/bash

#################################################################################
# virtual environment and dependencies                                          #
#################################################################################

.PHONY: venv
## create virtual environment
venv: ./.venv/.requirements

.venv:
	$(VIRTUALENV) $(PROJECT_DIR)/.venv
	$(PIP) install -U pip setuptools wheel

.venv/.requirements: .venv
	$(PIP) install -r $(PROJECT_DIR)/requirements.txt
	touch $(VENV)/.requirements

.PHONY: venv-clean
## clean virtual environment
venv-clean:
	rm -rf $(VENV)


#################################################################################
# conda environment and dependencies                                          	#
#################################################################################

.PHONY: cenv
## create conda env
cenv:
	conda create --name $(PROJECT_NAME) python=3

.PHONY: ckernel
## create conda jupyter kernel
ckernel: cenv
	source activate $(PROJECT_NAME)
	conda install ipykernel
	python -m ipykernel install --user --name $(PROJECT_NAME) --display-name "$(PROJECT_NAME)"

.PHONY: requirements
## install requirements
requirements:
	pip install -r $(PROJECT_DIR)/requirements.txt

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
