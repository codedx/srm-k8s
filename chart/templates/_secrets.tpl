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
Returns the MinIO secret name (overwrites template).
*/}}
{{- define "minio.secretName" -}}
{{- if (not .Values.global.minio.existingSecret) -}}
{{ include "srm-to.default.minio.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'global.minio.existingSecret' helm property" .Values.global.minio.existingSecret }}
{{- end -}}
{{- end -}}

{{/*
Get the root user key by switching the default from root-user to access-key (overwrites template).
*/}}
{{- define "minio.rootUserKey" -}}
{{- if and (.Values.auth.existingSecret) (.Values.auth.rootUserSecretKey) -}}
    {{- printf "%s" (tpl .Values.auth.rootUserSecretKey $) -}}
{{- else -}}
    {{/* Use the legacy name for key instead of root-user. */}}
    {{- "access-key" -}}
{{- end -}}
{{- end -}}

{{/*
Get the root password key by switching the default from root-password to secret-key (overwrites template).
*/}}
{{- define "minio.rootPasswordKey" -}}
{{- if and (.Values.auth.existingSecret) (.Values.auth.rootPasswordSecretKey) -}}
    {{- printf "%s" (tpl .Values.auth.rootPasswordSecretKey $) -}}
{{- else -}}
    {{/* Use the legacy name for password instead of root-password. */}}
    {{- "secret-key" -}}
{{- end -}}
{{- end -}}

{{/*
Returns the MinIO secret name.
*/}}
{{- define "minio.ref.secretName" -}}
{{- if (not .Values.minio.global.minio.existingSecret) -}}
{{ include "srm-to.default.minio.secret" . }}
{{- else -}}
{{ required "You must specify a value for the 'minio.global.minio.existingSecret' helm property" .Values.minio.global.minio.existingSecret }}
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
