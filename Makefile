HELM_REPO := akeneo-charts
HELM_URL :=  gs://$(HELM_REPO)/
HELM_CHART_NAME := collectd-exporter
HELM_CHART_VERSION ?= 0.0.0-0

.PHONY: helm-lint
helm-lint: 
	helm lint  ./$(HELM_CHART_NAME)/

.PHONY: helm-build
helm-build: helm-lint test-chart-exists
	helm package -u ./$(HELM_CHART_NAME)/ --version $(HELM_CHART_VERSION)
	helm gcs push ./$(HELM_CHART_NAME)-$(HELM_CHART_VERSION).tgz $(HELM_REPO)
	rm ./$(HELM_CHART_NAME)-$(HELM_CHART_VERSION).tgz

.PHONY: test-chart-exists
test-image-exists:
	$(info Check that chart is not existing yet : $(HELM_URL)$(HELM_CHART_NAME):$(HELM_CHART_VERSION))
	@helm repo update
	@$(eval CHART_EXISTS:=$(shell helm fetch $(HELM_REPO)/$(HELM_CHART_NAME) --version $(HELM_CHART_VERSION) 1>&2 2> /dev/null; echo $$?))
	@echo "Exist: $(CHART_EXISTS)"
	@if [ "$(CHART_EXISTS)" -eq "0" ] && [ "$(HELM_CHART_VERSION)" != "0.0.0-0" ]; \
		then \
			echo "WARNING: Chart $(HELM_URL)/$(HELM_CHART_NAME):$(HELM_CHART_VERSION) is ever existing!" ; \
			if [ ! -z "$(FORCE)" ] ; then echo "!!! FORCING EXISTING CHART REBUILD AND PUSH !!!" ; else exit 1; fi ; \
		else \
			echo "Let's continue" ; \
	fi
