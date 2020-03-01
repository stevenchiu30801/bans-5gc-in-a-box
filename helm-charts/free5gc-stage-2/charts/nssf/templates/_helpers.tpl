{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nssf.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nssf.fullname" -}}
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
{{- define "nssf.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "nssf.labels" -}}
helm.sh/chart: {{ include "nssf.chart" . }}
{{ include "nssf.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "nssf.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nssf.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "nssf.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "nssf.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
NSSF image
*/}}
{{- define "nssf.image" -}}
{{- if .Values.global.image.free5gc -}}
{{ .Values.global.image.free5gc.repository }}:{{ .Values.global.image.free5gc.tag }}
{{- else -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}

{{/*
S-NSSAI List
*/}}
{{- define "nssf.snssaiList" }}
{{- if .Values.global.enableSlices }}
{{- range $key, $val := .Values.global.slices }}
{{- toYaml $val | nindent 0 }}
{{- end }}
{{- else }}
- sst: 1
  sd: 010203
- sst: 1
  sd: 112233
{{- end }}
{{- end }}

{{/*
NSI List
*/}}
{{- define "nssf.nsiList" }}
{{- if .Values.global.enableSlices }}
{{- range $key, $val := .Values.global.slices }}
{{- range $val }}
- snssai:
    {{- toYaml . | nindent 4 }}
  nsiInformationList:
    - nrfId: https://{{ $.Values.global.nrf.addr }}:29510
{{- end }}
{{- end }}
{{- else }}
- snssai:
    sst: 1
    sd: 010203
  nsiInformationList:
    - nrfId: https://{{ .Values.global.nrf.addr }}:29510
- snssai:
    sst: 1
    sd: 112233
  nsiInformationList:
    - nrfId: https://{{ .Values.global.nrf.addr }}:29510
{{- end }}
{{- end }}
