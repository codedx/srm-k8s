{{- define "common.errors.insecureImages" -}}
{{/* Ignore the insecure images check. */}}
{{- end -}}

{{/*
Return false to block the subchart from creating a secret object (overwrites template).
*/}}
{{- define "minio.createSecret" -}}
{{/* Block the MinIO chart from creating its own K8s Secret resource. */}}
{{- false -}}
{{- end -}}

{{/*
Get the user to use to access MinIO&reg; (overwrites template).
*/}}
{{- define "minio.secret.userValue" -}}
{{- if (and (empty .Values.auth.rootUser) .Values.auth.forcePassword) }}
    {{ required "A root username is required!" .Values.auth.rootUser }}
{{- else -}}
    {{/* Ignore password management, which is handled in _secrets.tpl. */}}
    {{/* {{- include "common.secrets.passwords.manage" (dict "secret" (include "common.names.fullname" .) "key" "root-user" "providedValues" (list "auth.rootUser") "context" $) -}} */}}
{{- end -}}
{{- end -}}

{{/*
Get the password to use to access MinIO&reg; (overwrites template).
*/}}
{{- define "minio.secret.passwordValue" -}}
{{- if (and (empty .Values.auth.rootPassword) .Values.auth.forcePassword) }}
    {{ required "A root password is required!" .Values.auth.rootPassword }}
{{- else -}}
    {{/* Ignore password management, which is handled in _secrets.tpl. */}}
    {{/* {{- include "common.secrets.passwords.manage" (dict "secret" (include "common.names.fullname" .) "key" "root-password" "providedValues" (list "auth.rootPassword") "context" $) -}} */}}
{{- end -}}
{{- end -}}