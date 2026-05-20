{{/*
Official MinIO chart (charts.min.io) does not use Bitnami's common library,
so the Bitnami template-override helpers (minio.createSecret,
minio.secret.userValue, minio.secret.passwordValue, common.errors.insecureImages)
are no longer needed and have been removed.

Secret management is now handled entirely by the SRM chart:
  - to-default-storage-secret.yaml creates the secret when no existingSecret is set.
  - _secrets.tpl exposes minio.ref.secretName for consumers.
  - The official chart is pointed at that secret via minio.existingSecret.
*/}}
