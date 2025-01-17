{{/*
Expand the name of the chart.
*/}}
{{- define "sfu.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sfu.fullname" -}}
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
{{- define "sfu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Values.appVersionSfu | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "sfu-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Values.appVersionSfuManager | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{/*
Common labels
*/}}
{{- define "sfu.labels" -}}
helm.sh/chart: {{ include "sfu.chart" . }}
{{ include "sfu.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.appVersionSfu | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "sfu-manager.labels" -}}
helm.sh/chart: {{ include "sfu-manager.chart" . }}
{{ include "sfu-manager.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.appVersionSfuManager | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "sfu-job.labels" -}}
{{ include "sfu-manager.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sfu.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sfu.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "sfu-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sfu.name" . }}-manager
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
