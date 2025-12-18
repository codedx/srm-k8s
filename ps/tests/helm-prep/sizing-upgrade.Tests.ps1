using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
  'common.ps1',
  '../wizard-common/mock.ps1',
	'../../build/yaml.ps1',
	'../../external/powershell-algorithms/data-structures.ps1',
  '../../keyvalue.ps1',
  '../../build/protect.ps1',
  '../../config.ps1' | ForEach-Object {
		Write-Debug "'$PSCommandPath' is including file '$_'"
		$path = Join-Path $PSScriptRoot $_
		if (-not (Test-Path $path)) {
			Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
		}
		. $path | out-null
	}
}

Describe 'Using a v1.2 config.json file...' {

	It 'Core and Tool Orchestration features should use same default reservations' {

		New-Mocks

		$testDrivePath = Get-TestDriveDirectoryInfo
		$workDirPath = $testDrivePath.FullName.Replace('\','\\')
		$configJsonPath = Join-Path $testDrivePath 'config.json'

		# a default config.json (before system system was available) with Tool Orchestration
		@'
{
  "configVersion": "1.2",
  "namespace": "srm",
  "releaseName": "srm-release",
  "workDir": "~/.k8s-srm",
  "srmLicenseFile": "srm-web-license",
  "scanFarmSastLicenseFile": null,
  "scanFarmScaLicenseFile": null,
  "repoUsername": null,
  "repoPwd": null,
  "scanFarmDatabaseHost": null,
  "scanFarmDatabasePort": null,
  "scanFarmDatabaseUser": null,
  "scanFarmDatabasePwd": null,
  "scanFarmDatabaseSslMode": null,
  "scanFarmDatabaseServerCert": null,
  "scanFarmScanDatabaseCatalog": null,
  "scanFarmStorageDatabaseCatalog": null,
  "scanFarmRedisHost": null,
  "scanFarmRedisPort": null,
  "scanFarmRedisDatabase": null,
  "scanFarmRedisUseAuth": false,
  "scanFarmRedisPwd": null,
  "scanFarmRedisSecure": false,
  "scanFarmRedisVerifyHostname": false,
  "scanFarmRedisServerCert": null,
  "scanFarmStorageType": null,
  "scanFarmStorageBucketName": null,
  "scanFarmCacheBucketName": null,
  "scanFarmS3UseServiceAccountName": false,
  "scanFarmS3AccessKey": null,
  "scanFarmS3SecretKey": null,
  "scanFarmS3ServiceAccountName": null,
  "scanFarmS3Region": null,
  "scanFarmGcsProjectName": null,
  "scanFarmGcsSvcAccountKey": null,
  "scanFarmAzureStorageAccount": null,
  "scanFarmAzureStorageAccountKey": null,
  "scanFarmAzureSubscriptionId": null,
  "scanFarmAzureTenantId": null,
  "scanFarmAzureResourceGroup": null,
  "scanFarmAzureEndpoint": null,
  "scanFarmAzureClientId": null,
  "scanFarmAzureClientSecret": null,
  "scanFarmMinIOHostname": null,
  "scanFarmMinIOPort": null,
  "scanFarmMinIORootUsername": null,
  "scanFarmMinIORootPwd": null,
  "scanFarmMinIOSecure": false,
  "scanFarmMinIOVerifyHostname": false,
  "scanFarmMinIOServerCert": null,
  "scanFarmStorageHasInClusterUrl": false,
  "scanFarmStorageInClusterUrl": null,
  "scanFarmStorageIsProxied": true,
  "scanFarmStorageContextPath": "upload",
  "scanFarmStorageExternalUrl": "",
  "useGeneratedPwds": true,
  "mariadbRootPwd": null,
  "mariadbReplicatorPwd": null,
  "srmDatabaseUserPwd": null,
  "adminPwd": null,
  "toolServiceApiKey": null,
  "minioAdminPwd": null,
  "k8sProvider": "Other",
  "kubeApiTargetPort": "443",
  "clusterCertificateAuthorityCertPath": null,
  "csrSignerName": null,
  "createSCCs": false,
  "scanFarmType": 0,
  "skipDatabase": false,
  "useTriageAssistant": false,
  "skipScanFarm": true,
  "skipToolOrchestration": false,
  "skipMinIO": false,
  "skipNetworkPolicies": true,
  "skipTls": true,
  "toolServiceReplicas": 1,
  "dbSlaveReplicaCount": 1,
  "externalDatabaseHost": null,
  "externalDatabasePort": 3306,
  "externalDatabaseName": null,
  "externalDatabaseUser": null,
  "externalDatabasePwd": null,
  "externalDatabaseSkipTls": false,
  "externalDatabaseTrustCert": false,
  "externalDatabaseServerCert": null,
  "externalWorkflowStorageEndpoint": null,
  "externalWorkflowStorageEndpointSecure": false,
  "externalWorkflowStorageUsername": null,
  "externalWorkflowStoragePwd": null,
  "externalWorkflowStorageBucketName": null,
  "externalWorkflowStorageTrustCert": false,
  "externalWorkflowStorageCertChainPath": null,
  "addExtraCertificates": false,
  "extraTrustedCaCertPaths": null,
  "webServiceType": "ClusterIP",
  "webServicePortNumber": "9090",
  "webServiceAnnotations": [],
  "skipIngressEnabled": true,
  "ingressType": "ClusterIP",
  "ingressClassName": null,
  "ingressAnnotations": [],
  "ingressHostname": null,
  "ingressTlsSecretName": null,
  "ingressTlsType": null,
  "useSaml": false,
  "useLdap": false,
  "samlHostBasePath": null,
  "samlIdentityProviderMetadataPath": null,
  "samlAppName": null,
  "samlKeystorePwd": null,
  "samlPrivateKeyPwd": null,
  "skipDockerRegistryCredential": true,
  "dockerImagePullSecretName": null,
  "dockerRegistry": null,
  "dockerRegistryUser": null,
  "dockerRegistryPwd": null,
  "useDefaultDockerImages": true,
  "imageVersionWeb": null,
  "imageVersionMariaDB": null,
  "imageVersionTo": null,
  "imageVersionMinio": null,
  "imageVersionWorkflow": null,
  "useDockerRedirection": false,
  "useDockerRepositoryPrefix": false,
  "dockerRepositoryPrefix": null,
  "useDefaultCACerts": true,
  "caCertsFilePath": null,
  "caCertsFilePwd": null,
  "useCPUDefaults": true,
  "webCPUReservation": "2000m",
  "dbMasterCPUReservation": "2000m",
  "dbSlaveCPUReservation": "1000m",
  "toolServiceCPUReservation": "",
  "minioCPUReservation": "2000m",
  "workflowCPUReservation": "",
  "useMemoryDefaults": true,
  "webMemoryReservation": "8192Mi",
  "dbMasterMemoryReservation": "8192Mi",
  "dbSlaveMemoryReservation": "8192Mi",
  "toolServiceMemoryReservation": "500Mi",
  "minioMemoryReservation": "5120Mi",
  "workflowMemoryReservation": "500Mi",
  "useEphemeralStorageDefaults": true,
  "webEphemeralStorageReservation": "3368Mi",
  "dbMasterEphemeralStorageReservation": "",
  "dbSlaveEphemeralStorageReservation": "",
  "toolServiceEphemeralStorageReservation": "",
  "minioEphemeralStorageReservation": "",
  "workflowEphemeralStorageReservation": "",
  "useVolumeSizeDefaults": true,
  "webVolumeSizeGiB": 64,
  "dbVolumeSizeGiB": 64,
  "dbSlaveVolumeSizeGiB": 64,
  "dbSlaveBackupVolumeSizeGiB": 64,
  "minioVolumeSizeGiB": 64,
  "storageClassName": "",
  "useNodeSelectors": false,
  "webNodeSelector": null,
  "masterDatabaseNodeSelector": null,
  "subordinateDatabaseNodeSelector": null,
  "toolServiceNodeSelector": null,
  "minioNodeSelector": null,
  "workflowControllerNodeSelector": null,
  "toolNodeSelector": null,
  "useTolerations": false,
  "webNoScheduleExecuteToleration": null,
  "masterDatabaseNoScheduleExecuteToleration": null,
  "subordinateDatabaseNoScheduleExecuteToleration": null,
  "toolServiceNoScheduleExecuteToleration": null,
  "minioNoScheduleExecuteToleration": null,
  "workflowControllerNoScheduleExecuteToleration": null,
  "toolNoScheduleExecuteToleration": null,
  "notes": [],
  "salts": [],
  "isLocked": false,
  "scanFarmScaApiUrlOverride": null
}
'@.Replace('~/.k8s-srm', $workDirPath) | Out-File $configJsonPath

	$licenseFilePath = Join-Path $TestDrive 'srm-web-license'
	Write-Output $null > $licenseFilePath

	. (Join-Path $PSScriptRoot ../../helm-prep.ps1) -configPath $configJsonPath

	$valuesPath = Join-Path $TestDrive 'chart-values-combined/values-combined.yaml'

	$yaml = Get-Yaml $valuesPath

	$yaml.GetKeyValue(('web','resources','limits','cpu')) | Should -Be '2000m'
	$yaml.GetKeyValue(('web','resources','limits','memory')) | Should -Be '8192Mi'

	$yaml.GetKeyValue(('mariadb','master','resources','limits','cpu')) | Should -Be '2000m'
	$yaml.GetKeyValue(('mariadb','master','resources','limits','memory')) | Should -Be '8192Mi'
	$yaml.GetKeyValue(('mariadb','slave','resources','limits','cpu')) | Should -Be '1000m'
	$yaml.GetKeyValue(('mariadb','slave','resources','limits','memory')) | Should -Be '8192Mi'

	$yaml.GetKeyValue(('to','service','numReplicas')) | Should -Be '1'
	$yaml.GetKeyValue(('to','resources','limits','cpu')) | Should -BeNullOrEmpty
	$yaml.GetKeyValue(('to','resources','limits','memory')) | Should -Be '500Mi'

	$yaml.GetKeyValue(('minio','resources','limits','cpu')) | Should -Be '2000m'
	$yaml.GetKeyValue(('minio','resources','limits','memory')) | Should -Be '5120Mi'

	$yaml.GetKeyValue(('argo-workflows','controller','resources','limits','cpu')) | Should -BeNullOrEmpty
	$yaml.GetKeyValue(('argo-workflows','controller','resources','limits','memory')) | Should -Be '500Mi'

	$yaml.GetKeyValue(('web','persistence','size')) | Should -Be '64Gi'

	$yaml.GetKeyValue(('mariadb','master','persistence','size')) | Should -Be '64Gi'

	$yaml.GetKeyValue(('mariadb','slave','persistence','size')) | Should -Be '64Gi'
	$yaml.GetKeyValue(('mariadb','slave','persistence','backup','size')) | Should -Be '64Gi'

	$yaml.GetKeyValue(('minio','persistence','size')) | Should -Be '64Gi'
	}
}