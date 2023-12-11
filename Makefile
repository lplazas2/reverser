
export GCP_PROJECT_ID = bamboo-copilot-407420
export REGISTRY_NAME = prod-europe-west1-registry
export IMG_NAME = reverser
export REGION = europe-west1
export REGISTRY_BASE_DOMAIN = europe-west1-docker.pkg.dev

bootstrap:
	kubectl --context gke_bamboo-copilot-407420_europe-west1_prod-europe-west1-cluster create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'


kubectl-setup:
	gcloud container clusters get-credentials prod-europe-west1-cluster --region ${REGION} --project ${GCP_PROJECT_ID}

registry:
	gcloud auth configure-docker ${REGISTRY_BASE_DOMAIN}

bin/reverser:
	@ mkdir -p bin
	@ go build -o bin/reverser

IMG_TAG=latest
docker-build:
	@ docker buildx build --platform linux/amd64 . -t ${REGISTRY_BASE_DOMAIN}/${GCP_PROJECT_ID}/${REGISTRY_NAME}/${IMG_NAME}:${IMG_TAG}

IMG_TAG=latest
docker-push:
	@ docker push ${REGISTRY_BASE_DOMAIN}/${GCP_PROJECT_ID}/${REGISTRY_NAME}/${IMG_NAME}:${IMG_TAG}

## Runs the service locally on port 9090
IMG_TAG=latest
run:
	@ docker run -e DEBUG=true -e PORT=9090 -p 9090:9090 ${REGISTRY_BASE_DOMAIN}/${GCP_PROJECT_ID}/${REGISTRY_NAME}/${IMG_NAME}:${IMG_TAG}

## Formats all the ".tf" files
fmt:
	@ echo "-> Checking that the terraform .tf files are formatted..."
	@ terraform fmt -recursive -check