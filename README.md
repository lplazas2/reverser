# Reverser app

## Quickstart 
*Reversing logic:* The service reverses `50.159.22.10` as `10.22.159.50` (instead of `01.22.951.05`) to avoid invalid IPs with parts such as `05` and out of range numbers like `951`

- Local: 
Run `make run` to run the image locally, the registry being used is publicly readable.
- Remote: The app is running on: 34.149.5.56: 
  - `curl http://34.149.5.56`
  - `curl http://34.149.5.56 -H "X-Forwarded-For:50.159.22.10"`
- Run `make help` in the base directory for general local dev functionality

## Repo structure

* `./terraform`: contains all IaaC
  * `live/`: contains live code applied to Google Cloud.
  * `modules/`: contains tf modules
* `./helm`: contains the helm chart to deploy this app
  * `apps/`: App of apps for ArgoCD
  * `reverser/`: Helm chart for the reverser app.
* `./internal`: contains the Go code with the application, see also `./main.go`

## Architecture

TLDR: Golang app, distributed in a docker image, packaged in a Helm chart, built/tested as part of a CI pipeline in Github and deployed with ArgoCD on a Terraform provisioned GKE cluster.

TODO insert a diagram

## Future work / improvements
- Setup an actual DB, think about distributed state
- Organize and setup tf modules and live code for large scale infra (separate repos)
- Setup centralized telemetry for the service(s)
- Setup IAM for pods so that they can access other cloud resources
- Setup releases through tags, setup different build environments ... this is barebones CI
- Setup a way for the pods to autoscale as needed