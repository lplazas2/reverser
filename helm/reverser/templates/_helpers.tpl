{{- define "svcName" -}}
{{- default .Chart.Name .Values.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "namespaced_svcName" -}}
{{- printf "%s-%s" .Values.environment (include "svcName" .) | trunc 63 | trimSuffix "-" }}
{{- end }}