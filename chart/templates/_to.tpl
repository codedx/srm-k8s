{{- define "srm-to.name" -}}
{{- printf "%s-to" ((include "srm.name" .) | trunc 59 | trimSuffix "-") }}
{{- end }}

{{- define "srm-to.fullname" -}}
{{- printf "%s-to" ((include "srm.fullname" .) | trunc 59 | trimSuffix "-") }}
{{- end }}

{{- define "srm-to.pre-delete-job" -}}
{{- printf "%s-pre-delete-job" ((include "srm.fullname" .) | trunc 47 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.scc" -}}
{{- printf "%s-to-scc" ((include "srm.fullname" .) | trunc 55 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-workflow-controller.scc" -}}
{{- printf "%s-workflow-controller-scc" ((include "srm.fullname" .) | trunc 38 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.workflow-scc" -}}
{{- printf "%s-wf-to-scc" ((include "srm.fullname" .) | trunc 52 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.workflow.priorityClassName" -}}
{{- printf "%s-wf-pc" ((include "srm.fullname" .) | trunc 56 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.service.priorityClassName" -}}
{{- printf "%s-svc-pc" ((include "srm.fullname" .) | trunc 55 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.predelete.rolename" -}}
{{- printf "%s-pre-delete-role" ((include "srm.fullname" .) | trunc 46 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.predelete.rolebindingname" -}}
{{- printf "%s-pre-delete-rolebinding" ((include "srm.fullname" .) | trunc 39 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.rolename" -}}
{{- printf "%s-to-role" ((include "srm.fullname" .) | trunc 54 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.rolebindingname" -}}
{{- printf "%s-to-rolebinding" ((include "srm.fullname" .) | trunc 47 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-to.job-labels" -}}
helm.sh/chart: {{ include "srm.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "srm-to.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: cleanup
{{- end }}

{{- define "srm-to.labels" -}}
helm.sh/chart: {{ include "srm.chart" . }}
{{ include "srm-to.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "srm-to.selectorLabels" -}}
app.kubernetes.io/name: {{ include "srm-to.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: to
{{- end }}

{{/*
Create the name of the TO service account to use
*/}}
{{- define "srm-to.serviceAccountName" -}}
{{- if .Values.to.serviceAccount.create }}
{{- default (include "srm-to.fullname" .) .Values.to.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.to.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the TO workflow service account to use
*/}}
{{- define "srm-to.serviceAccountNameWorkflow" -}}
{{- index .Values "argo-workflows" "workflow" "serviceAccount" "name" -}}
{{- end }}

{{- define "srm-to.storageEndpoint" -}}
{{- if .Values.minio.enabled -}}
{{- print (include "minio.ref.fullname" .) "." .Release.Namespace ".svc.cluster.local:" .Values.minio.service.ports.api -}}
{{- else -}}
{{- .Values.to.workflowStorage.endpoint -}}
{{- end -}}
{{- end -}}

{{- define "srm-to.storageTlsEnabled" -}}
{{- $enabled := 0 -}}
{{- if (or .Values.to.workflowStorage.endpointSecure (and .Values.minio.enabled .Values.minio.tls.existingSecret)) -}}
{{- $enabled = 1 -}}
{{- end -}}
{{ $enabled }}
{{- end -}}

{{- define "srm-to.storageCredentialSecretName" -}}
{{- if .Values.features.minio -}}
{{- include "minio.ref.secretName" . -}}
{{- else if .Values.to.workflowStorage.existingSecret -}}
{{- .Values.to.workflowStorage.existingSecret -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{- define "srm-to.storageTlsConfigMapName" -}}
{{- .Values.to.workflowStorage.configMapName -}}
{{- end -}}

{{- define "srm-to.storageTlsConfigMapPublicCertName" -}}
{{- .Values.to.workflowStorage.configMapPublicCertKeyName -}}
{{- end -}}

{{/*
Determine the URL of the TO service.
*/}}
{{- define "srm-to.serviceurl" -}}
{{- $protocol := "http" }}
{{- if .Values.to.tlsSecret -}}
{{- $protocol = "https" -}}
{{- end -}}
{{- $protocol -}}://{{- include "srm-to.fullname" . -}}:{{- .Values.to.service.toolServicePort -}}
{{- end -}}

{{/*
Returns the default TO key secret name.
*/}}
{{- define "srm-to.default.key.secret" -}}
{{- printf "%s-default-key-secret" ((include "srm-to.fullname" .) | trunc 44 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the default MinIO secret name.
Note: Uses a fixed dependency chart name (minio) to support the context of an overridden template.
*/}}
{{- define "srm-to.default.minio.secret" -}}
{{- printf "%s-minio-default-secret" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Returns the TO service NetworkPolicy name.
*/}}
{{- define "srm-to.networkPolicyName" -}}
{{- printf "%s-to-netpol" ((include "srm.fullname" .) | trunc 53 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the Argo NetworkPolicy name.
*/}}
{{- define "srm-to.argo-networkPolicyName" -}}
{{- printf "%s-argo-netpol" ((include "srm.fullname" .) | trunc 51 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the MinIO NetworkPolicy name.
*/}}
{{- define "srm-to.minio-networkPolicyName" -}}
{{- printf "%s-minio-netpol" ((include "srm.fullname" .) | trunc 50 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the workflow NetworkPolicy name.
*/}}
{{- define "srm-to.workflow-networkPolicyName" -}}
{{- printf "%s-workflow-netpol" ((include "srm.fullname" .) | trunc 47 | trimSuffix "-") }}
{{- end -}}

{{/*
Create NetworkPolicy TCP port ranges.
*/}}
{{- define "srm-to.netpolicy.egress.ports.tcp" -}}
{{- $portData := dict "ports" .Values.networkPolicy.to.egress.extraPorts.tcp "protocol" "TCP" -}}
{{- include "netpolicy.ports" $portData -}}
{{- end -}}

{{/*
Create NetworkPolicy UDP port ranges.
*/}}
{{- define "srm-to.netpolicy.egress.ports.udp" -}}
{{- $portData := dict "ports" .Values.networkPolicy.to.egress.extraPorts.udp "protocol" "UDP" -}}
{{- include "netpolicy.ports" $portData -}}
{{- end -}}

{{/*
Duplicates of a Minio template helper so we can reference Minio's service name
*/}}

{{- define "minio.ref.name" -}}
{{- default "minio" .Values.minio.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "minio.ref.fullname" -}}
{{- if .Values.minio.fullnameOverride -}}
{{- .Values.minio.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "minio" .Values.minio.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "minio.ref.serviceAccountName" -}}
{{- if .Values.minio.serviceAccount.create -}}
{{- default (include "minio.ref.fullname" .) .Values.minio.serviceAccount.name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- default "default" .Values.minio.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Duplicates of an Argo template helper so we can reference the Argo controller's service name
*/}}

{{- define "argo-workflows.ref.fullname" -}}
{{- $workflowValues := index .Values "argo-workflows" -}}
{{- if $workflowValues.fullnameOverride -}}
{{- $workflowValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "argo-workflows" $workflowValues.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "argo-workflows.ref.controller.fullname" -}}
{{- printf "%s-%s" (include "argo-workflows.ref.fullname" .) (index .Values "argo-workflows" "controller" "name") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "argo-workflows.ref.controllerServiceAccountName" -}}
{{- $serviceAccount := index .Values "argo-workflows" "controller" "serviceAccount" -}}
{{- if $serviceAccount.create -}}
    {{ default (include "argo-workflows.ref.controller.fullname" .) $serviceAccount.name }}
{{- else -}}
    {{ default "default" $serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the PVC name, potentially forcing a switch to the single-node, single-drive configuration (overwrites template).
*/}}
{{- define "minio.claimName" -}}
{{- if and .Values.persistence.existingClaim }}
    {{- printf "%s" (tpl .Values.persistence.existingClaim $) -}}
{{- else -}}
    {{- printf "%s-snsd" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}