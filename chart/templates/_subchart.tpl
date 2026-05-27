{{/*
Official MinIO chart (charts.min.io) does not use Bitnami's common library,
so the Bitnami template-override helpers (minio.createSecret,
minio.secret.userValue, minio.secret.passwordValue, common.errors.insecureImages)
are no longer needed and have been removed.

Secret wiring for the official MinIO chart (charts.min.io).

The official MinIO chart reads credentials from the secret named by
minio.existingSecret.  When existingSecret is set to a non-empty value the
chart skips creating its own secret (which would contain default minioadmin
credentials).

The SRM chart sets minio.existingSecret to the auto-generated secret name
(see values-to.yaml) so that:
  1. MinIO skips its own secret creation.
  2. to-default-storage-secret.yaml creates the secret with both
     rootUser/rootPassword (for MinIO) and access-key/secret-key (for the
     tool service), ensuring both consumers share the same credentials.

No template overrides are required here; the wiring is done entirely through
the minio.existingSecret value.
*/}}
