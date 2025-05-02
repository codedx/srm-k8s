function Get-ClusterCaConfigMapName() {
	'srm-ca-configmap'
}

function New-ClusterCaConfig($config) {

	# resource name comes from default setting in values-tls.yaml
	$resourceName = Get-ClusterCaConfigMapName

	New-ConfigMap $config.namespace $resourceName -fileKeyValues @{
		"ca.crt"=$config.clusterCertificateAuthorityCertPath
	} -dryRun | Out-File (Get-ClusterCaCertCfgMapK8sPath $config)

	if (-not $config.skipToolOrchestration) {

		# tool orchestration loads clusterCertificateAuthorityCertPath from a K8s secret
		New-GenericSecret $config.namespace $resourceName -fileKeyValues @{
			"ca.crt"=$config.clusterCertificateAuthorityCertPath
		} -dryRun | Out-File (Get-ClusterCaCertSecretK8sPath $config)
	}
}

function New-CertManagerCertificateConfig($config) {
	@"
tls:
  certManager:
    enabled: true
    issuerRef:
      name: $($config.certManagerIssuerName)
      kind: $($config.certManagerIssuerType)
"@ | Out-File (Get-CertManagerCertificateK8sPath $config)
}

function New-TlsCertSignerConfig($config) {

@"
`$CA_PATH='$($config.clusterCertificateAuthorityCertPath)'
`$SRM_NAMESPACE='$($config.namespace)'
`$SRM_RELEASE_NAME='$($config.releaseName)'
`$CERT_SIGNER='$($config.csrSignerName)'

`$HAS_FEATURE_MARIADB=$(-not $config.skipDatabase ? '$true' : '$false')
`$HAS_FEATURE_TO=$(-not $config.skipToolOrchestration ? '$true' : '$false')
`$HAS_FEATURE_MINIO=$(-not $config.skipToolOrchestration -and -not $config.skipMinIO ? '$true' : '$false')

`$SRM_WEB_SECRET_NAME='srm-web-tls-secret'
`$SRM_DB_SECRET_NAME='srm-db-tls-secret'
`$SRM_TO_SECRET_NAME='srm-to-tls-secret'
`$SRM_MINIO_SECRET_NAME='srm-minio-tls-secret'

`$SRM_TEMP_WORK_DIR='$($config.GetTempWorkDir())'
Push-Location `$SRM_TEMP_WORK_DIR

`$global:PSNativeCommandArgumentPassing='Legacy'
Install-Module guided-setup -RequiredVersion 1.18.0

# Create SRM namespace (if necessary)
if (-not (Test-Namespace '$($config.namespace)')) {
	New-Namespace '$($config.namespace)'
}

# Create SRM web certificate
`$webSvcName = "`$(Get-HelmChartFullnameEquals `$SRM_RELEASE_NAME 'srm')-web"
New-Certificate `$CERT_SIGNER `$CA_PATH `$webSvcName `$webSvcName './web-tls.crt' './web-tls.key' `$SRM_NAMESPACE

# Create SRM web Secret
New-CertificateSecretResource `$SRM_NAMESPACE `$SRM_WEB_SECRET_NAME './web-tls.crt' './web-tls.key'

if (`$HAS_FEATURE_MARIADB) {

	# Create primary DB certificate (required for deployments using an on-cluster MariaDB)
	`$dbSvcName = Get-HelmChartFullnameContains `$SRM_RELEASE_NAME 'mariadb'
	New-Certificate `$CERT_SIGNER `$CA_PATH `$dbSvcName `$dbSvcName './db-tls.crt' './db-tls.key' `$SRM_NAMESPACE

	# Create primary DB Secret (required for deployments using an on-cluster MariaDB)
	New-CertificateSecretResource `$SRM_NAMESPACE `$SRM_DB_SECRET_NAME './db-tls.crt' './db-tls.key'
}

if (`$HAS_FEATURE_TO) {

	# Create TO certificate (required for deployments using Tool Orchestration)
	`$toSvcName = "`$(Get-HelmChartFullnameEquals `$SRM_RELEASE_NAME 'srm')-to"
	New-Certificate `$CERT_SIGNER `$CA_PATH `$toSvcName `$toSvcName './to-tls.crt' './to-tls.key' `$SRM_NAMESPACE

	# Create TO Secret (required for deployments using Tool Orchestration)
	New-CertificateSecretResource `$SRM_NAMESPACE `$SRM_TO_SECRET_NAME './to-tls.crt' './to-tls.key'
}

if (`$HAS_FEATURE_MINIO) {

	# Create MinIO certificate (required for deployments using an on-cluster, built-in MinIO)
	`$minioSvcName = Get-HelmChartFullnameContains `$SRM_RELEASE_NAME 'minio'
	New-Certificate `$CERT_SIGNER `$CA_PATH `$minioSvcName `$minioSvcName './minio-tls.crt' './minio-tls.key' `$SRM_NAMESPACE

	# Create MinIO Secret (required for deployments using an on-cluster, built-in MinIO)
	New-GenericSecret `$SRM_NAMESPACE `$SRM_MINIO_SECRET_NAME -fileKeyValues @{'tls.crt'='./minio-tls.crt'; 'tls.key'='./minio-tls.key'; 'ca.crt'=`$CA_PATH}
}

Write-Host "`nNote that the '`$SRM_TEMP_WORK_DIR' directory contains .key files and other configuration data that should be kept private.`n"
Pop-Location
"@ | Out-File (Get-K8sCsrScriptPath($config))
}

function New-TlsConfig($config) {

	New-ClusterCaConfig $config

	if ($config.IsUsingCertManagerCertificates()) {
		New-CertManagerCertificateConfig $config
	} elseif ($config.IsUsingK8sCertificateSigningRequest()) {
		New-TlsCertSignerConfig $config
	}
}