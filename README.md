# Reverser app

## Quickstart 
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

TODO insert a diagram

## Future work / improvements
- Setup an actual DB, think about distributed state
- Organize and setup tf modules and live code for large scale infra (separate repos)
- Setup centralized telemetry for the service(s)
- Setup IAM for pods so that they can access other cloud resources
- Setup releases through tags, beef up CI
- Setup a way for the pods to autoscale as needed