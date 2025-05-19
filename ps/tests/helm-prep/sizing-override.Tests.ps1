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

Describe 'Specifying an ignored system size...' -Tag 'size' {

	It 'Core feature should permit overrides' {

		New-Mocks

		$testDrivePath = Get-TestDriveDirectoryInfo
		$workDirPath = $testDrivePath.FullName.Replace('\','\\')
		$configJsonPath = Join-Path $testDrivePath 'config.json'

		# a default config.json with Medium system size that gets ignored for CPU, memory, and volume sizing
		@'
{
  "configVersion": "1.3",
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
  "useTriageAssistant": true,
  "skipScanFarm": true,
  "skipToolOrchestration": true,
  "skipMinIO": false,
  "skipNetworkPolicies": true,
  "skipTls": true,
  "toolServiceReplicas": 0,
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
  "useCPUDefaults": false,
  "webCPUReservation": "21000m",
  "dbMasterCPUReservation": "22000m",
  "dbSlaveCPUReservation": "23000m",
  "toolServiceCPUReservation": null,
  "minioCPUReservation": null,
  "workflowCPUReservation": null,
  "useMemoryDefaults": false,
  "webMemoryReservation": "21000Mi",
  "dbMasterMemoryReservation": "22000Mi",
  "dbSlaveMemoryReservation": "23000Mi",
  "toolServiceMemoryReservation": null,
  "minioMemoryReservation": null,
  "workflowMemoryReservation": null,
  "useEphemeralStorageDefaults": false,
  "webEphemeralStorageReservation": null,
  "dbMasterEphemeralStorageReservation": null,
  "dbSlaveEphemeralStorageReservation": null,
  "toolServiceEphemeralStorageReservation": null,
  "minioEphemeralStorageReservation": null,
  "workflowEphemeralStorageReservation": null,
  "useVolumeSizeDefaults": false,
  "webVolumeSizeGiB": 1,
  "dbVolumeSizeGiB": 2,
  "dbSlaveVolumeSizeGiB": 3,
  "dbSlaveBackupVolumeSizeGiB": 4,
  "minioVolumeSizeGiB": 0,
  "storageClassName": "",
  "systemSize": "Medium",
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
		$yaml.GetKeyValue(('sizing','size')) | Should -Be 'Medium'
		
		$yaml.GetKeyValue(('web','resources','limits','cpu')) | Should -Be '21000m'
		$yaml.GetKeyValue(('web','resources','limits','memory')) | Should -Be '21000Mi'
		$yaml.GetKeyValue(('mariadb','master','resources','limits','cpu')) | Should -Be '22000m'
		$yaml.GetKeyValue(('mariadb','master','resources','limits','memory')) | Should -Be '22000Mi'
		$yaml.GetKeyValue(('mariadb','slave','resources','limits','cpu')) | Should -Be '23000m'
		$yaml.GetKeyValue(('mariadb','slave','resources','limits','memory')) | Should -Be '23000Mi'

		$yaml.GetKeyValue(('web','persistence','size')) | Should -Be '1Gi'

		$yaml.GetKeyValue(('mariadb','master','persistence','size')) | Should -Be '2Gi'
		
		$yaml.GetKeyValue(('mariadb','slave','persistence','size')) | Should -Be '3Gi'
		$yaml.GetKeyValue(('mariadb','slave','persistence','backup','size')) | Should -Be '4Gi'
	}

	It 'Tool Orchestration feature should not include reservations' {

		New-Mocks

    $testDrivePath = Get-TestDriveDirectoryInfo
		$workDirPath = $testDrivePath.FullName.Replace('\','\\')
		$configJsonPath = Join-Path $testDrivePath 'config.json'

		# a default config.json with Medium system size with Tool Orchestration that gets ignored for CPU, memory, and volume sizing
		@'
{
  "configVersion": "1.3",
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
  "useTriageAssistant": true,
  "skipScanFarm": true,
  "skipToolOrchestration": false,
  "skipMinIO": false,
  "skipNetworkPolicies": true,
  "skipTls": true,
  "toolServiceReplicas": 34,
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
  "useCPUDefaults": false,
  "webCPUReservation": "31000m",
  "dbMasterCPUReservation": "32000m",
  "dbSlaveCPUReservation": "33000m",
  "toolServiceCPUReservation": "35000m",
  "minioCPUReservation": "36000m",
  "workflowCPUReservation": "37000m",
  "useMemoryDefaults": false,
  "webMemoryReservation": "31000Mi",
  "dbMasterMemoryReservation": "32000Mi",
  "dbSlaveMemoryReservation": "33000Mi",
  "toolServiceMemoryReservation": "35000Mi",
  "minioMemoryReservation": "36000Mi",
  "workflowMemoryReservation": "37000Mi",
  "useEphemeralStorageDefaults": false,
  "webEphemeralStorageReservation": null,
  "dbMasterEphemeralStorageReservation": null,
  "dbSlaveEphemeralStorageReservation": null,
  "toolServiceEphemeralStorageReservation": null,
  "minioEphemeralStorageReservation": null,
  "workflowEphemeralStorageReservation": null,
  "useVolumeSizeDefaults": false,
  "webVolumeSizeGiB": 1,
  "dbVolumeSizeGiB": 2,
  "dbSlaveVolumeSizeGiB": 3,
  "dbSlaveBackupVolumeSizeGiB": 4,
  "minioVolumeSizeGiB": 5,
  "storageClassName": "",
  "systemSize": "Medium",
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
		$yaml.GetKeyValue(('sizing','size')) | Should -Be 'Medium'

		$yaml.GetKeyValue(('web','resources','limits','cpu')) | Should -Be '31000m'
		$yaml.GetKeyValue(('web','resources','limits','memory')) | Should -Be '31000Mi'

		$yaml.GetKeyValue(('mariadb','master','resources','limits','cpu')) | Should -Be '32000m'
		$yaml.GetKeyValue(('mariadb','master','resources','limits','memory')) | Should -Be '32000Mi'
		$yaml.GetKeyValue(('mariadb','slave','resources','limits','cpu')) | Should -Be '33000m'
		$yaml.GetKeyValue(('mariadb','slave','resources','limits','memory')) | Should -Be '33000Mi'

		$yaml.GetKeyValue(('to','service','numReplicas')) | Should -Be '34'
		$yaml.GetKeyValue(('to','resources','limits','cpu')) | Should -Be '35000m'
		$yaml.GetKeyValue(('to','resources','limits','memory')) | Should -Be '35000Mi'

		$yaml.GetKeyValue(('minio','resources','limits','cpu')) | Should -Be '36000m'
		$yaml.GetKeyValue(('minio','resources','limits','memory')) | Should -Be '36000Mi'

		$yaml.GetKeyValue(('argo-workflows','controller','resources','limits','cpu')) | Should -Be '37000m'
		$yaml.GetKeyValue(('argo-workflows','controller','resources','limits','memory')) | Should -Be '37000Mi'

		$yaml.GetKeyValue(('web','persistence','size')) | Should -Be '1Gi'

		$yaml.GetKeyValue(('mariadb','master','persistence','size')) | Should -Be '2Gi'
		
		$yaml.GetKeyValue(('mariadb','slave','persistence','size')) | Should -Be '3Gi'
		$yaml.GetKeyValue(('mariadb','slave','persistence','backup','size')) | Should -Be '4Gi'

		$yaml.GetKeyValue(('minio','persistence','size')) | Should -Be '5Gi'
	}
}
