{{- define "srm-sf.scanSvcName" -}}
{{- printf "%s-scan-service" .Release.Name }}
{{- end }}

{{- define "srm-sf.storageSvcName" -}}
{{- printf "%s-storage-service" .Release.Name }}
{{- end -}}

{{- define "srm-sf.cacheSvcName" -}}
{{- printf "%s-cache-service" .Release.Name }}
{{- end -}}

{{- define "srm-sf.scanSvcUrl" -}}
{{- printf "http://%s:9998" (include "srm-sf.scanSvcName" .) }}
{{- end }}

{{- define "srm-sf.storageSvcUrl" -}}
{{- printf "http://%s:9998" (include "srm-sf.storageSvcName" .) }}
{{- end -}}

{{- define "srm-sf.svc-job" -}}
{{- printf "%s-internal-svc-job" ((include "srm.fullname" .) | trunc 45 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-sf.svc-cronjob" -}}
{{- printf "%s-internal-svc-cronjob" ((include "srm.fullname" .) | trunc 41 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-sf.svc-job-labels" -}}
helm.sh/chart: {{ include "srm.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "srm-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: configuration
{{- end }}

{{- define "srm-sf.assert-sast-version" -}}
{{- include "srm-sf.assert-tool-version" (dict "type" "SAST" "version" .Values.web.scanfarm.sast.version "supportedVersions" (list "2024.12.0" "2024.9.1" "2024.3.0" "2023.9.2" "2023.6.1")) -}}
{{- end -}}

{{- define "srm-sf.assert-sca-version" -}}
{{- include "srm-sf.assert-tool-version" (dict "type" "SCA" "version" .Values.web.scanfarm.sca.version "supportedVersions" (list "10.0.0" "9.2.0" "8.9.0")) -}}
{{- end -}}

{{- define "srm-sf.assert-tool-version" -}}
    {{- if has .version .supportedVersions -}}
        {{- .version -}}
    {{- else -}}
        {{- fail (printf "%s is not a supported %s tool version; use one of these tested values instead: %s" .version .type (toString .supportedVersions)) -}}
    {{- end -}}
{{- end -}}