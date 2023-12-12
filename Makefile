.DEFAULT_GOAL = help
SHELL := /bin/bash
export GCP_PROJECT_ID = bamboo-copilot-407420
export REGISTRY_NAME = prod-europe-west1-registry
export GKE_CLUSTER_NAME = prod-europe-west1-cluster
export IMG_NAME = reverser
export REGION = europe-west1
export REGISTRY_BASE_DOMAIN = europe-west1-docker.pkg.dev

.PHONY: bootstrap
bootstrap:
	kubectl --context gke_${GCP_PROJECT_ID}_${REGION}_${GKE_CLUSTER_NAME} create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

.PHONY: kubectl-setup
kubectl-setup: ## Setup kubectl auth
	gcloud container clusters get-credentials prod-europe-west1-cluster --region ${REGION} --project ${GCP_PROJECT_ID}

.PHONY: config-registry
config-registry: ## Local config registry
	gcloud auth configure-docker ${REGISTRY_BASE_DOMAIN}

bin/reverser: ## Build reverser locally
	@ mkdir -p bin
	@ go build -o bin/reverser

IMG_TAG=latest
.PHONY: docker-build
docker-build: ## Build the reverser-svc docker image
	@ docker buildx build --platform linux/amd64 . -t ${REGISTRY_BASE_DOMAIN}/${GCP_PROJECT_ID}/${REGISTRY_NAME}/${IMG_NAME}:${IMG_TAG}

IMG_TAG=latest
.PHONY: docker-push
docker-push: ## Push the reverser-svc docker image
	@ docker push ${REGISTRY_BASE_DOMAIN}/${GCP_PROJECT_ID}/${REGISTRY_NAME}/${IMG_NAME}:${IMG_TAG}

IMG_TAG=latest
.PHONY: run
run: ## Run the reverser backend locally on port 9090
	@ docker run -e DEBUG=true -e PORT=9090 -p 9090:9090 ${REGISTRY_BASE_DOMAIN}/${GCP_PROJECT_ID}/${REGISTRY_NAME}/${IMG_NAME}:${IMG_TAG}

.PHONY: fmt
fmt: ## format terraform and go code
	@ gofmt -l -s -w .
	@ terraform fmt -recursive -check

.PHONY: help
help: ## this help
	@ awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m\t%s\n", $$1, $$2 }' $(MAKEFILE_LIST) | column -s$$'\t' -t