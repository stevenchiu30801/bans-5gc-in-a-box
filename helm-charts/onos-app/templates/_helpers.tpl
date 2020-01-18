{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "onos-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "onos-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "onos-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "onos-app.labels" -}}
helm.sh/chart: {{ include "onos-app.chart" . }}
{{ include "onos-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "onos-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "onos-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "onos-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "onos-app.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Expand the argument of ONOS APP name
*/}}
{{- define "onos-app.argAppName" -}}
{{- if .Values.appName -}}
, "{{ .Values.appName }}"
{{- end -}}
{{- end -}}

{{/*
Expand the argument of path to ONOS APP
*/}}
{{- define "onos-app.argAppFile" -}}
{{- if .Values.appFile -}}
, "/oars/{{ .Values.appFile }}"
{{- end -}}
{{- end -}}

{{/*
Expand the arugments of onos-app command
*/}}
{{- define "onos-app.cmdArgs" -}}
"{{ .Values.onosGuiService }}", "{{ .Values.appCommand }}"{{ include "onos-app.argAppName" . }}{{ include "onos-app.argAppFile" . }}
{{- end -}}
