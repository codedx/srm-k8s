using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
	. (Join-Path $PSScriptRoot '../wizard-common/mock.ps1')
	. (Join-Path $PSScriptRoot '../../keyvalue.ps1')
	. (Join-Path $PSScriptRoot '../../build/protect.ps1')
	. (Join-Path $PSScriptRoot '../../config.ps1')
}

Describe 'Running the add SAML authentication wizard' -Tag 'size' {

	It 'Should not change config.json on abort' {

		$configJsonPath = Join-Path $TestDrive 'config.json'
		@'
		{
			"configVersion": "1.4",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "work-dir-placeholder",
			"srmLicenseFile": "work-dir-placeholder\\srm-web-license.txt",
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
			"workflowStorageType": "OnCluster",
			"serviceAccountToolService": "",
			"serviceAccountWorkflow": "",
			"toolServiceReplicas": 0,
			"dbSlaveReplicaCount": 0,
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
			"webCPUReservation": null,
			"dbMasterCPUReservation": null,
			"dbSlaveCPUReservation": null,
			"toolServiceCPUReservation": null,
			"minioCPUReservation": null,
			"workflowCPUReservation": null,
			"useMemoryDefaults": false,
			"webMemoryReservation": null,
			"dbMasterMemoryReservation": null,
			"dbSlaveMemoryReservation": null,
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
			"webVolumeSizeGiB": 0,
			"dbVolumeSizeGiB": 0,
			"dbSlaveVolumeSizeGiB": 0,
			"dbSlaveBackupVolumeSizeGiB": 0,
			"minioVolumeSizeGiB": 0,
			"storageClassName": "",
			"systemSize": "Small",
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
'@.Replace('work-dir-placeholder', (Resolve-Path $TestDrive).Path.Replace('\', '\\')) | Out-file $configJsonPath

		$global:inputs = new-object collections.queue
		$null, # welcome
		1 # abort (Use SAML)
		| ForEach-Object {
			$global:inputs.enqueue($_)
		}

		New-Mocks

		. (Join-Path $PSScriptRoot ../../features/add-samlauth.ps1) -configPath $configJsonPath

		$configFileContents = Get-Content $configJsonPath
		$configBackupFileContents = Get-Content "$configJsonPath.bak"
		[string]::Join('', $configFileContents) -eq [string]::Join('', $configBackupFileContents) | Should -BeTrue
	}

	It 'Should add SAML config' {

		$configJsonPath = Join-Path $TestDrive 'config.json'
		@'
		{
			"configVersion": "1.4",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "work-dir-placeholder",
			"srmLicenseFile": "work-dir-placeholder\\srm-web-license.txt",
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
			"workflowStorageType": "OnCluster",
			"serviceAccountToolService": "",
			"serviceAccountWorkflow": "",
			"toolServiceReplicas": 0,
			"dbSlaveReplicaCount": 0,
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
			"webCPUReservation": null,
			"dbMasterCPUReservation": null,
			"dbSlaveCPUReservation": null,
			"toolServiceCPUReservation": null,
			"minioCPUReservation": null,
			"workflowCPUReservation": null,
			"useMemoryDefaults": false,
			"webMemoryReservation": null,
			"dbMasterMemoryReservation": null,
			"dbSlaveMemoryReservation": null,
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
			"webVolumeSizeGiB": 0,
			"dbVolumeSizeGiB": 0,
			"dbSlaveVolumeSizeGiB": 0,
			"dbSlaveBackupVolumeSizeGiB": 0,
			"minioVolumeSizeGiB": 0,
			"storageClassName": "",
			"systemSize": "Small",
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
'@.Replace('work-dir-placeholder', (Resolve-Path $TestDrive).Path.Replace('\', '\\')) | Out-file $configJsonPath

		$global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (Use SAML Authentication)
		'https://my-srm.blackduck.com/srm', # (SRM SAML hostBasePath)
		'idp-metadata-path', # (SAML Identity Provider Metadata)
		'saml-client', # (SAML Application Name)
		(New-Password 'password'), # (SAML Keystore Password)
		(New-Password 'password'), # confirm (SAML Keystore Password)
		(New-Password 'password'), # (SAML Private Key Password)
		(New-Password 'password'), # confirm (SAML Private Key Password)
		0, # (SAML Extra Config)
		(New-Password 'password'), # (Lock Config JSON)
		(New-Password 'password'), # confirm (Lock Config JSON)
		0 # save (Finish)
		| ForEach-Object {
			$global:inputs.enqueue($_)
		}

		New-Mocks

		Mock -ModuleName Guided-Setup Test-Path {
			$true
		} -ParameterFilter { 'idp-metadata-path' -contains $path }

		. (Join-Path $PSScriptRoot ../../features/add-samlauth.ps1) -configPath $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)

		$configFileContents = Get-Content $configJsonPath
		$configBackupFileContents = Get-Content "$configJsonPath.bak"
		[string]::Join('', $configFileContents) -eq [string]::Join('', $configBackupFileContents) | Should -BeFalse

		$config.isLocked | Should -BeTrue
		$config.useSaml | Should -BeTrue
		$config.samlHostBasePath | Should -BeExactly 'https://my-srm.blackduck.com/srm'
		$config.samlIdentityProviderMetadataPath | Should -BeExactly 'idp-metadata-path'
		$config.samlAppName | Should -BeExactly 'saml-client'

		$config.Unlock('password')
		$config.isLocked | Should -BeFalse
		$config.samlKeystorePwd | Should -BeExactly 'password'
		$config.samlPrivateKeyPwd | Should -BeExactly 'password'
	}
}