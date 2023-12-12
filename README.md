# Reverser app

## TLDR 
- Local: 
Run `make run` to run the image locally, the registry being used is publicly readable.
- Remote: The app is running on: `google` 

## Repo structure: 

* `./terraform`: contains all IaaC
  * `live/`: contains live code applied to CSP.
  * `modules/`: contains tf modules
* `./helm`: contains the helm chart to deploy this app
* `./internal`: contains the Go code with the application, see also `./main.go`

## future work:
- Setup an actual DB
- Organize and setup tf modules and live code for large scale infra
- Setup centralized telemetry for the service(s)
- Setup IAM for pods so that they can access other cloud resources