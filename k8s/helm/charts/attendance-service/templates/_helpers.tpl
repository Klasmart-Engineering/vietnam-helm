{{/*
Expand the name of the chart.
*/}}
{{- define "attendance_service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "attendance_service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "attendance_service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Values.appVersion | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "attendance_service.labels" -}}
helm.sh/chart: {{ include "attendance_service.chart" . }}
{{ include "attendance_service.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.appVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "attendance_service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "attendance_service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Nginx Ingress ConfigMap labels
*/}}
{{- define "attendance_service.nginxIngressConfigMapLabels" -}}
app: nginx-ingress
app.kubernetes.io/component: controller
component: controller
{{- end }}

