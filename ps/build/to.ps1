function Get-ToStorageSecretName($config) {
	"$($config.releaseName)-to-storage-secret"
}
function Get-ToStorageCertConfigMapName($config) {
	"$($config.releaseName)-to-storage-configmap"
}

function Get-ToKeyPropsSecretName($config) {
	"$($config.releaseName)-to-key-props-secret"
}

function Get-ToKeySecretName($config) {
	"$($config.releaseName)-to-key-secret"
}

function New-ToKeyPropsFile($config) {

	@"
tws.api-key = """$($config.toolServiceApiKey)"""
"@ | Out-File (Get-ToKeyPropsPath $config)
}

function New-ToKeyPropsSecret($config) {

	New-ToKeyPropsFile $config
	New-GenericSecret $config.namespace (Get-ToKeyPropsSecretName $config) -fileKeyValues @{
		"to-key.props"=$(Get-ToKeyPropsPath $config)
	} -dryRun | Out-File (Get-ToKeyK8sPath $config)
}

function New-ToKeySecret($config) {

	New-GenericSecret $config.namespace (Get-ToKeySecretName $config) -keyValues @{
		"api-key"=$config.toolServiceApiKey
	} -dryRun | Out-File (Get-ToCredentialK8sPath $config)

	@"
to:
  toSecret: $(Get-ToKeySecretName $config)
web:
  toSecret: $(Get-ToKeyPropsSecretName $config)
"@ | Out-File (Get-ToCredentialValuesPath $config)
}

function New-ToStorageSecret($config, $storageUsername, $storagePwd) {

	# The secret must satisfy two consumers:
	#   1. SRM tool service mounts access-key / secret-key
	#   2. Official MinIO chart reads rootUser / rootPassword from existingSecret
	New-GenericSecret $config.namespace (Get-ToStorageSecretName $config) -keyValues @{
		"access-key"=$storageUsername
		"secret-key"=$storagePwd
		"rootUser"=$storageUsername
		"rootPassword"=$storagePwd
	} -dryRun | Out-File (Get-ToWorkflowStorageSecretK8sPath $config)
}

function New-ExternalWorkflowStorage($config) {

	$workflowStorageSecret = ''
	if ($config.workflowStorageType -ne [WorkflowStorageType]::AwsIAM) {

		New-ToStorageSecret $config $config.externalWorkflowStorageUsername $config.externalWorkflowStoragePwd
		$workflowStorageSecret = Get-ToStorageSecretName $config
	}

	$yaml = @"
to:
  workflowStorage:
    endpoint: $($config.externalWorkflowStorageEndpoint)
    endpointSecure: $(ConvertTo-Json $config.externalWorkflowStorageEndpointSecure)
    existingSecret: $workflowStorageSecret
    bucketName: $($config.externalWorkflowStorageBucketName)
"@ | Out-File (Get-ToExternalWorkflowStoragePath $config)

	if ($config.workflowStorageType -eq [WorkflowStorageType]::AwsIAM) {
		@"
to:
  serviceAccount:
    create: false
    name: $($config.serviceAccountToolService)
argo-workflows:
  workflow:
    serviceAccount:
      create: false
      name: $($config.serviceAccountWorkflow)
"@ | Out-File (Get-ToExternalWorkflowStorageServiceAccountPath $config)
	}

	if (-not $config.externalWorkflowStorageTrustCert) {

		# zero out the default TLS configuration found in values-tls.yaml, the values-combined.yaml file
		# appears after values-tls.yaml in the generated helm command, so these overrides will apply
		@"
to:
  workflowStorage:
    configMapName:
    configMapPublicCertKeyName:
"@ | Out-File (Get-ToExternalCertWorkflowStoragePath $config)

	} else {

		# reference trusted CA chain optionally required for workflow storage
		$wfConfigMapName = Get-ToStorageCertConfigMapName $config
		New-ConfigMap $config.namespace $wfConfigMapName -fileKeyValues @{
			"wf-storage.pem"=$config.externalWorkflowStorageCertChainPath
		} -dryRun | Out-File (Get-ToExternalWorkflowStorageCertK8sPath $config)

		# a K8s Secret resource with the same name as the ConfigMap is required
		# for workflow steps to use a trusted cert chain
		New-GenericSecret $config.namespace $wfConfigMapName -fileKeyValues @{
			"wf-storage.pem" = $config.externalWorkflowStorageCertChainPath
		} -dryRun | Out-File (Get-ToExternalWorkflowStorageCertSecretK8sPath $config)
	
		@"
to:
  workflowStorage:
    configMapName: $wfConfigMapName
    configMapPublicCertKeyName: wf-storage.pem
"@ | Out-File (Get-ToExternalCertWorkflowStoragePath $config)

	}
}

function New-InternalWorkflowStorage($config) {

	if ($config.useGeneratedPwds) {
		return
	}

	New-ToKeyPropsSecret $config
	New-ToKeySecret $config

	New-ToStorageSecret $config 'admin' $config.minioAdminPwd
	@"
minio:
	 existingSecret: $(Get-ToStorageSecretName $config)
"@ | Out-File (Get-ToWorkflowStoragePath $config)
}

function New-ToolOrchestrationConfig($config) {

	if ($config.skipMinIO) {
		New-ExternalWorkflowStorage $config
	} else {
		New-InternalWorkflowStorage $config
	}

	$minioEnabled = $(ConvertTo-Json (-not $config.skipMinIO))
	@"
features:
	 minio: $minioEnabled
"@ | Out-File (Get-ToConfigMinIOValuesPath $config)

	if ($config.toolServiceReplicas -gt 0) {
		@"
to:
  service:
    numReplicas: $($config.toolServiceReplicas)
"@ | Out-File (Get-ToConfigValuesPath $config)
	}

	# incorporate chart name into argo-workflows controller priority class name
	$chartFullName = Get-HelmChartFullnameEquals $config.releaseName 'srm'
	$controllerPriorityClassNamePrefix = $chartFullName.substring(0, ([Math]::Min($chartFullName.length, 45))).TrimEnd('-')
	$controllerPriorityClassName = "$controllerPriorityClassNamePrefix-wf-controller-pc"
	@"
argo-workflows:
  controller:
    priorityClassName: $controllerPriorityClassName
"@ | Out-File (Get-ToConfigPriorityClassValuesPath $config)

	@"
argo-workflows:
  controller:
    workflowNamespaces:
    - "$($config.namespace)"
"@ | Out-File (Get-ToConfigWorkflowNamespaceValuesPath $config)
}