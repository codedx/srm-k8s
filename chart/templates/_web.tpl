{{- define "srm-web.name" -}}
{{- printf "%s-web" ((include "srm.name" .) | trunc 59 | trimSuffix "-") }}
{{- end }}

{{- define "srm-web.fullname" -}}
{{- printf "%s-web" ((include "srm.fullname" .) | trunc 59 | trimSuffix "-") }}
{{- end }}

{{- define "srm-web.db.fullname" -}}
{{- $name := "mariadb" -}}
{{- if contains $name .Release.Name -}}
{{- printf .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Common web labels
*/}}
{{- define "srm-web.labels" -}}
helm.sh/chart: {{ include "srm.chart" . }}
{{ include "srm-web.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector web labels
*/}}
{{- define "srm-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "srm-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: web
{{- end }}

{{/*
Create the name of the web service account to use
*/}}
{{- define "srm-web.serviceAccountName" -}}
{{- if .Values.web.serviceAccount.create }}
{{- default (include "srm-web.fullname" .) .Values.web.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.web.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "srm-web.rolename" -}}
{{- printf "%s-role" ((include "srm.fullname" .) | trunc 57 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-web.rolebindingname" -}}
{{- printf "%s-rolebinding" ((include "srm.fullname" .) | trunc 50 | trimSuffix "-") }}
{{- end -}}

{{/*
Determine the URL of the SRM web service.
*/}}
{{- define "srm-web.serviceurl" -}}
{{- $protocol := "http" }}
{{- if .Values.web.tlsSecret -}}
{{- $protocol = "https" -}}
{{- end -}}
{{- $protocol -}}://{{- include "srm-web.fullname" . -}}:{{- .Values.web.service.port -}}/{{- include "srm-web.appName" . -}}
{{- end -}}

{{/*
Determine the name of the volume to create and/or use for SRM web's "appdata" storage.
*/}}
{{- define "srm-web.volume.fullname" -}}
    {{- if .Values.web.persistence.existingClaim -}}
        {{- .Values.web.persistence.existingClaim -}}
    {{- else -}}
        {{- printf "%s-%s" .Release.Name "appdata" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
    {{- end -}}
{{- end -}}

{{/*
Determine the name of the configmap to create and/or use for holding SRM web files.
*/}}
{{- define "srm-web.props.configMapName" -}}
{{- printf "%s-%s" .Release.Name "configmap" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Determine the name of the server.xml ConfigMap to create and/or use for holding SRM web files.
*/}}
{{- define "srm-web.props.serverConfigMapName" -}}
{{- printf "%s-%s" .Release.Name "server-configmap" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Determine the name of the configmap to use for the SRM web `logback.xml` file.
*/}}
{{- define "srm-web.props.loggingConfigMapName" -}}
    {{- if .Values.web.loggingConfigMap -}}
        {{- .Values.web.loggingConfigMap -}}
    {{- else -}}
        {{- include "srm-web.props.configMapName" . -}}
    {{- end -}}
{{- end -}}

{{/*
Returns the default MariaDB secret name. 
Note: Uses a fixed dependency chart name (mariadb) to support the context of an overridden template.
*/}}
{{- define "srm-web.default.db.secret" -}}
{{- printf "%s-mariadb-default-secret" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Returns the default MariaDB web secret name.
*/}}
{{- define "srm-web.default.web.db.secret" -}}
{{- printf "%s-default-web-db-secret" ((include "srm.fullname" .) | trunc 41 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the default key web secret name.
*/}}
{{- define "srm-web.default.web.key.secret" -}}
{{- printf "%s-default-web-key-secret" ((include "srm.fullname" .) | trunc 40 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the default web secret name.
*/}}
{{- define "srm-web.default.web.secret" -}}
{{- printf "%s-default-web-secret" ((include "srm.fullname" .) | trunc 44 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the SCC name for the srm-web component.
*/}}
{{- define "srm-web.scc" -}}
{{- printf "%s-web-scc" ((include "srm.fullname" .) | trunc 54 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the SCC name for the srm-web component.
*/}}
{{- define "srm-web.database.scc" -}}
{{- printf "%s-web-db-scc" ((include "srm.fullname" .) | trunc 54 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the name of the MariaDB service account name.
*/}}
{{- define "srm-web.database.serviceAccountName" -}}
{{- if .Values.mariadb.serviceAccount.create -}}
    {{ default (include "srm-web.db.fullname" .) .Values.mariadb.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.mariadb.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Returns the web PriorityClass name.
*/}}
{{- define "srm-web.priorityClassName" -}}
{{- printf "%s-web-pc" ((include "srm.fullname" .) | trunc 56 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the web NetworkPolicy name.
*/}}
{{- define "srm-web.networkPolicyName" -}}
{{- printf "%s-web-netpol" ((include "srm.fullname" .) | trunc 52 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the primary DB NetworkPolicy name.
*/}}
{{- define "srm-web.primary-db-networkPolicyName" -}}
{{- printf "%s-pri-db-netpol" ((include "srm.fullname" .) | trunc 49 | trimSuffix "-") }}
{{- end -}}

{{/*
Returns the secondary DB NetworkPolicy name.
*/}}
{{- define "srm-web.secondary-db-networkPolicyName" -}}
{{- printf "%s-sec-db-netpol" ((include "srm.fullname" .) | trunc 49 | trimSuffix "-") }}
{{- end -}}

{{/*
Create NetworkPolicy TCP port ranges.
*/}}
{{- define "srm-web.netpolicy.egress.ports.tcp" -}}
{{- $portData := dict "ports" .Values.networkPolicy.web.egress.extraPorts.tcp "protocol" "TCP" -}}
{{- include "netpolicy.ports" $portData -}}
{{- end -}}

{{/*
Create NetworkPolicy UDP port ranges.
*/}}
{{- define "srm-web.netpolicy.egress.ports.udp" -}}
{{- $portData := dict "ports" .Values.networkPolicy.web.egress.extraPorts.udp "protocol" "UDP" -}}
{{- include "netpolicy.ports" $portData -}}
{{- end -}}

{{/*
Determine the web context path.
*/}}
{{- define "srm-web.appName" -}}
{{- default "srm" .Values.web.appName -}}
{{- end -}}

{{/*
Determine the web readiness path.
*/}}
{{- define "srm-web.readinessProbePath" -}}
{{- printf "%s/x/system-status/ready" (include "srm-web.appName" .) }}
{{- end -}}

{{/*
Determine the web liveness path.
*/}}
{{- define "srm-web.livenessProbePath" -}}
{{- printf "%s/x/system-status/alive" (include "srm-web.appName" .) }}
{{- end -}}