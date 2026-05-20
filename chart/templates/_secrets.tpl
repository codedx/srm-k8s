{{/*
Returns the web secret name.
*/}}
{{- define "srm-web.web.secret" -}}
{{- if (not .Values.web.webSecret) -}}
{{ include "srm-web.default.web.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'web.webSecret' helm property" .Values.web.webSecret }}
{{- end -}}
{{- end -}}

{{/*
Returns the web database credential secret name.
*/}}
{{- define "srm-web.database-credential.secret" -}}
{{- if and (and .Values.features.mariadb (not .Values.mariadb.existingSecret)) (not .Values.web.database.credentialSecret) -}}
{{ include "srm-web.default.web.db.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'web.database.credentialSecret' helm property" .Values.web.database.credentialSecret }}
{{- end -}}
{{- end -}}

{{/*
Returns the MariaDB credential secret name (overwrites template).
*/}}
{{- define "mariadb.secretName" -}}
{{- if (not .Values.existingSecret) -}}
{{ include "srm-web.default.db.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'mariadb.existingSecret' helm property" .Values.existingSecret }}
{{- end -}}
{{- end -}}

{{/*
Returns the MinIO secret name used by the official MinIO chart sub-chart.
The official MinIO chart (charts.min.io) reads credentials from the secret
named by minio.existingSecret, expecting keys rootUser and rootPassword.
The SRM-generated secret (to-default-storage-secret.yaml) stores the same
credential under access-key / secret-key so that the tool service can mount
them without change.  We therefore create the secret with BOTH sets of keys.
*/}}
{{- define "minio.ref.secretName" -}}
{{- if (not .Values.minio.existingSecret) -}}
{{ include "srm-to.default.minio.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'minio.existingSecret' helm property" .Values.minio.existingSecret }}
{{- end -}}
{{- end -}}

{{/*
Returns the TO key secret name.
*/}}
{{- define "srm-to.to.secret" -}}
{{- if and (and .Values.features.to (not .Values.web.toSecret)) (not .Values.to.toSecret) -}}
{{ include "srm-to.default.key.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'to.toSecret' helm property" .Values.to.toSecret }}
{{- end -}}
{{- end -}}

{{/*
Returns the web TO key secret name.
*/}}
{{- define "srm-web.to.secret" -}}
{{- if and (and .Values.features.to (not .Values.web.toSecret)) (not .Values.to.toSecret) -}}
{{ include "srm-web.default.web.key.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'web.toSecret' helm property" .Values.web.toSecret }}
{{- end -}}
{{- end -}}
