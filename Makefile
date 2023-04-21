.DEFAULT_GOAL := help

help:
	@awk \
		'BEGIN 					{FS = ":.*##"; printf "\n\033[1mUsage:\033[0m\n  make \033[36m[ COMMAND ]\n" } \
		/^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } \
		/^##@/                  { printf "\n\033[1m%s:\033[0m\n", substr($$0, 5) }' \
		$(MAKEFILE_LIST)

##@ Commands

.PHONY: all
all: node-image cluster crun-workload crun-test clean docker ## Build cluster and run the example workload

.PHONY: kind
node-image: ## Build the custom kind node image
	docker buildx build --tag kind-crun-wasm kind/image/node/

.PHONY: cluster
cluster: ## Create the cluster
	kind create cluster --config kind/kind.yaml
	kubectl apply --filename kind/runtime.yaml

.PHONY: crun-workload
crun-workload: ## Build a wasm workload image and load it into kind
	docker buildx build --tag wasm-workload:v0.1.0 example/crun/workload/
	kind load docker-image wasm-workload:v0.1.0 --name wasm

.PHONY: test-crun
crun-test: ## Deploy a test job with mixed workloads and print their logs
	kubectl apply --filename example/crun/crun.yaml
	kubectl wait job/mixed-workload --for=condition=complete --timeout=1m
	kubectl logs job/mixed-workload --container wasm
	kubectl logs job/mixed-workload --container regular

.PHONY: teardown
clean: ## Delete the kind cluster
	kind delete cluster --name wasm

.PHONY: clean-machine
docker: ## Clear all from machine
	docker system prune --all --force --volumes
