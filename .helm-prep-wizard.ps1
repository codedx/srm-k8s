<#PSScriptInfo
.VERSION 1.13.0
.GUID 0ab56564-8d45-485c-829a-bffed0882237
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }
param (
	[string] $previousConfigPath
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

Write-Host 'Loading...' -NoNewline

'ps/keyvalue.ps1',
'ps/build/protect.ps1',
'ps/config.ps1',
'ps/steps/step.ps1',
'ps/steps/auth.ps1',
'ps/steps/cpu.ps1',
'ps/steps/database.ps1',
'ps/steps/ephemeralstorage.ps1',
'ps/steps/finish.ps1',
'ps/steps/image.ps1',
'ps/steps/ingress.ps1',
'ps/steps/java.ps1',
'ps/steps/k8s.ps1',
'ps/steps/license.ps1',
'ps/steps/memory.ps1',
'ps/steps/pwd.ps1',
'ps/steps/reg.ps1',
'ps/steps/scanfarm.ps1',
'ps/steps/scanfarm-cache.ps1',
'ps/steps/scanfarm-db.ps1',
'ps/steps/scanfarm-storage.ps1',
'ps/steps/schedule.ps1',
'ps/steps/size.ps1',
'ps/steps/storage.ps1',
'ps/steps/tls.ps1',
'ps/steps/to.ps1',
'ps/steps/volume.ps1',
'ps/steps/welcome.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

# Check for keytool (required for validating certs and cacerts file)
if ($null -eq (Get-AppCommandPath keytool)) {
	Write-ErrorMessageAndExit "Restart this script after adding Java JRE (specifically Java's keytool program) to your PATH environment variable."
}

$previousConfig = $null
if ("" -ne $previousConfigPath) {

	$previousConfig = [Config]::FromJsonFile($previousConfigPath)
	if ($previousConfig.isLocked) {
		$previousConfig.Unlock((Read-HostSecureText -Prompt "`nEnter config file password"))	
	}
}

$config = [Config]::new()

$graph = New-Object Graph($true)

$s = @{}
[About],
[Abort],
[AddExtraCertificates],
[AdminPassword],
[AuthCookieSecure],
[AuthenticationType],
[CACertsFile],
[CACertsFilePassword],
[CertsCAPath],
[CertManagerIssuer],
[CertificateIssuerName],
[CertificateIssuerType],
[ChooseEnvironment],
[DatabaseReplicaCount],
[DatabaseReplicationPwd],
[DatabaseRootPwd],
[DatabaseUserPwd],
[DefaultCPU],
[DefaultEphemeralStorage],
[DefaultMemory],
[DefaultVolumeSize],
[DockerRepositoryPrefix],
[DockerRegistryHost],
[DockerRegistryPwd],
[DockerRegistryUser],
[DockerImagePullSecret],
[ExternalDatabaseAuth],
[ExternalDatabaseCert],
[ExternalDatabaseHost],
[ExternalDatabasePort],
[ExternalDatabaseName],
[ExternalDatabaseUser],
[ExternalDatabasePwd],
[ExternalDatabaseOneWayAuth],
[ExternalDatabaseServiceAccount],
[ExternalDatabaseTrustCert],
[ExternalStorageEndpoint],
[ExternalStorageTLS],
[ExternalStorageUsername],
[ExternalStoragePassword],
[ExternalStorageBucket],
[ExternalStorageTrustCert],
[ExternalStorageCertificate],
[ExtraCertificates],
[Finish],
[GeneratePwds],
[GetKubernetesPort],
[IngressCertificateArn],
[IngressClassName],
[IngressHostname],
[IngressKind],
[IngressTLS],
[IngressTLSSecretName],
[LdapInstructions],
[Lock],
[MariaDBDockerImageVersion],
[MasterDatabaseCPU],
[MasterDatabaseEphemeralStorage],
[MasterDatabaseMemory],
[MasterDatabaseNodeSelector],
[MasterDatabaseTolerations],
[MasterDatabaseVolumeSize],
[MinioAdminPassword],
[MinioDockerImageVersion],
[MinIOCPU],
[MinIOEphemeralStorage],
[MinIOMemory],
[MinIONodeSelector],
[MinIOTolerations],
[MinIOVolumeSize],
[Namespace],
[ToolOrchestrationDockerImageVersion],
[ReleaseName],
[UseExternalDatabase],
[UseExternalStorage],
[SamlAppName],
[SamlAuthenticationHostBasePath],
[SamlExtraConfig],
[SamlIdpMetadata],
[SamlKeystorePwd],
[SamlPrivateKeyPwd],
[ScanFarmAzureClientId],
[ScanFarmAzureClientSecret],
[ScanFarmAzureEndpoint],
[ScanFarmAzureResourceGroup],
[ScanFarmAzureStorageAccountName],
[ScanFarmAzureStorageAccountKey],
[ScanFarmAzureSubscription],
[ScanFarmAzureTenantId],
[ScanFarmCacheBucketName],
[ScanFarmStorageServiceDatabaseName],
[ScanFarmDatabaseCert],
[ScanFarmDatabaseHost],
[ScanFarmDatabasePort],
[ScanFarmDatabasePwd],
[ScanFarmDatabaseTls],
[ScanFarmDatabaseUsername],
[ScanFarmGcsKey],
[ScanFarmGcsProjectName],
[ScanFarmInClusterStorage],
[ScanFarmInClusterStorageUrl],
[ScanFarmObjectStorageCert],
[ScanFarmObjectStorageHostname],
[ScanFarmObjectStoragePort],
[ScanFarmObjectStorageSecretKey],
[ScanFarmObjectStorageAccessKey],
[ScanFarmObjectStorageTLS],
[ScanFarmRedisAuth],
[ScanFarmRedisCert],
[ScanFarmRedisDatabase],
[ScanFarmRedisHost],
[ScanFarmRedisPassword],
[ScanFarmRedisPort],
[ScanFarmRedisRequirements],
[ScanFarmRedisTls],
[ScanFarmSastLicense],
[ScanFarmScaLicense],
[ScanFarmS3AccessKey],
[ScanFarmS3AccessMethod],
[ScanFarmS3IamRoleServiceAccount],
[ScanFarmS3SecretKey],
[ScanFarmS3StorageContextPath],
[ScanFarmS3StorageExternalURL],
[ScanFarmS3StorageProxy],
[ScanFarmS3Region],
[ScanFarmScanServiceDatabaseName],
[ScanFarmStorage],
[ScanFarmStorageBucketName],
[ScanFarmType],
[ServiceAccountNameToolService],
[ServiceAccountNameWorkflow],
[SignerName],
[RepoUsername],
[RepoPassword],
[Size],
[SrmWebLicense],
[StorageClassName],
[SubordinateDatabaseBackupVolumeSize],
[SubordinateDatabaseCPU],
[SubordinateDatabaseEphemeralStorage],
[SubordinateDatabaseMemory],
[SubordinateDatabaseNodeSelector],
[SubordinateDatabaseTolerations],
[SubordinateDatabaseVolumeSize],
[ToolNodeSelector],
[ToolServiceCPU],
[ToolServiceEphemeralStorage],
[ToolServiceKey],
[ToolServiceMemory],
[ToolServiceNodeSelector],
[ToolServiceReplicaCount],
[ToolServiceTolerations],
[ToolTolerations],
[UseDefaultCACerts],
[UseNetworkPolicyOption],
[UseNodeSelectors],
[UseDockerRegistry],
[UseDockerRegistryCredential],
[UseDockerRepositoryPrefix],
[UseDefaultDockerImages],
[UseScanFarm],
[UseTlsOption],
[UseTolerations],
[UseToolOrchestration],
[Welcome],
[WebCPU],
[WebDockerImageVersion],
[WebEphemeralStorage],
[WebMemory],
[WebVolumeSize],
[WorkDir],
[WorkflowControllerNodeSelector],
[WorkflowControllerTolerations],
[WorkflowCPU],
[WorkflowDockerImageVersion],
[WorkflowEphemeralStorage],
[WorkflowMemory],
[WebNodeSelector],
[WebTolerations] | ForEach-Object {
	Write-Debug "Creating $_ object..."
	$step = new-object -type $_ -args $config
	$step.previousConfig = $previousConfig
	$s[$_] = $step
	Add-Step $graph $s[$_]
}

Add-StepTransitions $graph $s[[UseScanFarm]] $s[[RepoUsername]],$s[[RepoPassword]],$s[[ScanFarmType]],$s[[ScanFarmSastLicense]],$s[[ScanFarmScaLicense]],
	$s[[ScanFarmDatabaseHost]],$s[[ScanFarmDatabasePort]],$s[[ScanFarmDatabaseUsername]],$s[[ScanFarmDatabasePwd]],
	$s[[ScanFarmDatabaseTls]],$s[[ScanFarmDatabaseCert]],$s[[ScanFarmScanServiceDatabaseName]],$s[[ScanFarmStorageServiceDatabaseName]],
	$s[[ScanFarmRedisRequirements]],$s[[ScanFarmRedisHost]],$s[[ScanFarmRedisPort]],$s[[ScanFarmRedisDatabase]],
	$s[[ScanFarmRedisAuth]],$s[[ScanFarmRedisPassword]],$s[[ScanFarmRedisTls]],$s[[ScanFarmRedisCert]],
	$s[[ScanFarmStorage]],$s[[ScanFarmStorageBucketName]],$s[[ScanFarmCacheBucketName]]

Add-StepTransitions $graph $s[[ScanFarmType]] $s[[ScanFarmScaLicense]]
Add-StepTransitions $graph $s[[ScanFarmSastLicense]] $s[[ScanFarmDatabaseHost]]

Add-StepTransitions $graph $s[[ScanFarmCacheBucketName]] $s[[ScanFarmObjectStorageHostname]],$s[[ScanFarmObjectStoragePort]],$s[[ScanFarmObjectStorageAccessKey]],$s[[ScanFarmObjectStorageSecretKey]],$s[[ScanFarmS3StorageProxy]],$s[[ScanFarmS3StorageContextPath]],$s[[ScanFarmInClusterStorage]],$s[[ScanFarmInClusterStorageUrl]],$s[[ScanFarmObjectStorageTLS]],$s[[ScanFarmObjectStorageCert]],$s[[DockerRegistryHost]]
Add-StepTransitions $graph $s[[ScanFarmS3StorageProxy]] $s[[ScanFarmS3StorageExternalURL]],$s[[ScanFarmInClusterStorage]]
Add-StepTransitions $graph $s[[ScanFarmInClusterStorage]] $s[[ScanFarmObjectStorageTLS]]
Add-StepTransitions $graph $s[[ScanFarmObjectStorageTLS]] $s[[DockerRegistryHost]]
Add-StepTransitions $graph $s[[ScanFarmCacheBucketName]] $s[[ScanFarmS3AccessMethod]],$s[[ScanFarmS3AccessKey]],$s[[ScanFarmS3SecretKey]],$s[[ScanFarmS3Region]],$s[[DockerRegistryHost]]
Add-StepTransitions $graph $s[[ScanFarmCacheBucketName]] $s[[ScanFarmS3AccessMethod]],$s[[ScanFarmS3IamRoleServiceAccount]],$s[[ScanFarmS3Region]],$s[[DockerRegistryHost]]
Add-StepTransitions $graph $s[[ScanFarmCacheBucketName]] $s[[ScanFarmGcsProjectName]],$s[[ScanFarmGcsKey]],$s[[DockerRegistryHost]]
Add-StepTransitions $graph $s[[ScanFarmCacheBucketName]] $s[[ScanFarmAzureSubscription]],$s[[ScanFarmAzureTenantId]],$s[[ScanFarmAzureResourceGroup]],$s[[ScanFarmAzureStorageAccountName]],$s[[ScanFarmAzureStorageAccountKey]],$s[[ScanFarmAzureEndpoint]],$s[[ScanFarmAzureClientId]],$s[[ScanFarmAzureClientSecret]],$s[[DockerRegistryHost]]

Add-StepTransitions $graph $s[[UseToolOrchestration]] $s[[UseExternalStorage]]

Add-StepTransitions $graph $s[[UseExternalDatabase]] $s[[ExternalDatabaseHost]],$s[[ExternalDatabasePort]],$s[[ExternalDatabaseName]],$s[[ExternalDatabaseUser]],$s[[ExternalDatabaseAuth]],$s[[ExternalDatabasePwd]],$s[[ExternalDatabaseOneWayAuth]],$s[[ExternalDatabaseTrustCert]],$s[[ExternalDatabaseCert]],$s[[UseScanFarm]]
Add-StepTransitions $graph $s[[ExternalDatabaseAuth]] $s[[ExternalDatabaseServiceAccount]],$s[[ExternalDatabaseCert]]

Add-StepTransitions $graph $s[[Welcome]] $s[[About]], `
	$s[[Size]],
	$s[[SrmWebLicense]],
	$s[[WorkDir]],
	$s[[ChooseEnvironment]],
	$s[[Namespace]],
	$s[[ReleaseName]],
	$s[[UseExternalDatabase]],
	$s[[DatabaseReplicaCount]],
	$s[[UseScanFarm]],
	$s[[UseDockerRegistry]],$s[[DockerRegistryHost]],
	$s[[UseDockerRegistryCredential]],$s[[DockerImagePullSecret]],$s[[DockerRegistryUser]],$s[[DockerRegistryPwd]],
	$s[[UseToolOrchestration]],$s[[ToolServiceReplicaCount]],
	$s[[UseExternalStorage]],$s[[ServiceAccountNameToolService]],$s[[ServiceAccountNameWorkflow]],
	$s[[ExternalStorageEndpoint]],$s[[ExternalStorageTLS]],$s[[ExternalStorageUsername]],$s[[ExternalStoragePassword]],$s[[ExternalStorageBucket]],$s[[ExternalStorageTrustCert]],$s[[ExternalStorageCertificate]],
	$s[[UseTlsOption]],$s[[CertsCAPath]],$s[[SignerName]],
	$s[[UseNetworkPolicyOption]],$s[[GetKubernetesPort]],
	$s[[AuthenticationType]],$s[[SamlAuthenticationHostBasePath]],$s[[SamlIdpMetadata]],$s[[SamlAppName]],$s[[SamlKeystorePwd]],$s[[SamlPrivateKeyPwd]],$s[[SamlExtraConfig]],
	$s[[IngressKind]],$s[[IngressClassName]],$s[[IngressTLS]],$s[[CertManagerIssuer]],$s[[IngressHostname]],
	$s[[UseDefaultCACerts]],$s[[CACertsFile]],$s[[CACertsFilePassword]],$s[[AddExtraCertificates]],$s[[ExtraCertificates]],
	$s[[GeneratePwds]],$s[[AdminPassword]],$s[[DatabaseRootPwd]],$s[[DatabaseReplicationPwd]],$s[[DatabaseUserPwd]],$s[[ToolServiceKey]],$s[[MinioAdminPassword]],
	$s[[UseDockerRepositoryPrefix]],$s[[DockerRepositoryPrefix]],
	$s[[UseDefaultDockerImages]],$s[[WebDockerImageVersion]],$s[[MariaDBDockerImageVersion]],$s[[ToolOrchestrationDockerImageVersion]],$s[[MinioDockerImageVersion]],$s[[WorkflowDockerImageVersion]],
	$s[[DefaultCPU]],$s[[WebCPU]],$s[[MasterDatabaseCPU]],$s[[SubordinateDatabaseCPU]],$s[[ToolServiceCPU]],$s[[MinIOCPU]],$s[[WorkflowCPU]],
	$s[[DefaultMemory]],$s[[WebMemory]],$s[[MasterDatabaseMemory]],$s[[SubordinateDatabaseMemory]],$s[[ToolServiceMemory]],$s[[MinIOMemory]],$s[[WorkflowMemory]],
	$s[[DefaultEphemeralStorage]],$s[[WebEphemeralStorage]],$s[[MasterDatabaseEphemeralStorage]],$s[[SubordinateDatabaseEphemeralStorage]],$s[[ToolServiceEphemeralStorage]],$s[[MinIOEphemeralStorage]],$s[[WorkflowEphemeralStorage]],
	$s[[DefaultVolumeSize]],$s[[WebVolumeSize]],$s[[MasterDatabaseVolumeSize]],$s[[SubordinateDatabaseVolumeSize]],$s[[SubordinateDatabaseBackupVolumeSize]],$s[[MinIOVolumeSize]],$s[[StorageClassName]],$s[[AuthCookieSecure]],
	$s[[UseNodeSelectors]],$s[[WebNodeSelector]],$s[[MasterDatabaseNodeSelector]],$s[[SubordinateDatabaseNodeSelector]],$s[[ToolServiceNodeSelector]],$s[[MinIONodeSelector]],$s[[WorkflowControllerNodeSelector]],$s[[ToolNodeSelector]],$s[[UseTolerations]],
	$s[[WebTolerations]],$s[[MasterDatabaseTolerations]],$s[[SubordinateDatabaseTolerations]],$s[[ToolServiceTolerations]],$s[[MinIOTolerations]],$s[[WorkflowControllerTolerations]],$s[[ToolTolerations]],
	$s[[Lock]],$s[[Finish]]

Add-StepTransitions $graph $s[[ToolOrchestrationDockerImageVersion]] $s[[WorkflowDockerImageVersion]]

Add-StepTransitions $graph $s[[ExternalStorageTLS]] $s[[ExternalStorageBucket]]

Add-StepTransitions $graph $s[[ToolTolerations]] $s[[Finish]]

Add-StepTransitions $graph $s[[AuthenticationType]] $s[[LdapInstructions]],$s[[IngressKind]]
Add-StepTransitions $graph $s[[AuthenticationType]] $s[[IngressKind]]

Add-StepTransitions $graph $s[[IngressTLS]] $s[[IngressTLSSecretName]],$s[[IngressHostname]]
Add-StepTransitions $graph $s[[IngressTLS]] $s[[IngressHostname]]
Add-StepTransitions $graph $s[[IngressKind]] $s[[IngressCertificateArn]],$s[[UseDefaultCACerts]]
Add-StepTransitions $graph $s[[IngressKind]] $s[[UseDefaultCACerts]]

Add-StepTransitions $graph $s[[IngressKind]] $s[[CACertsFile]]
Add-StepTransitions $graph $s[[IngressCertificateArn]] $s[[CACertsFile]]
Add-StepTransitions $graph $s[[IngressHostname]] $s[[CACertsFile]]

Add-StepTransitions $graph $s[[AddExtraCertificates]] $s[[GeneratePwds]]

Add-StepTransitions $graph $s[[UseExternalDatabase]] $s[[DatabaseReplicaCount]]
Add-StepTransitions $graph $s[[ExternalDatabaseOneWayAuth]] $s[[UseScanFarm]]
Add-StepTransitions $graph $s[[ExternalDatabaseTrustCert]] $s[[UseScanFarm]]
Add-StepTransitions $graph $s[[ExternalDatabaseCert]] $s[[UseScanFarm]]

Add-StepTransitions $graph $s[[UseTlsOption]] $s[[UseNetworkPolicyOption]]
Add-StepTransitions $graph $s[[UseNetworkPolicyOption]] $s[[AuthenticationType]]

Add-StepTransitions $graph $s[[ScanFarmDatabaseTls]] $s[[ScanFarmScanServiceDatabaseName]]
Add-StepTransitions $graph $s[[ScanFarmRedisAuth]] $s[[ScanFarmRedisTls]]
Add-StepTransitions $graph $s[[ScanFarmRedisTls]] $s[[ScanFarmStorage]]

Add-StepTransitions $graph $s[[UseDockerRegistry]] $s[[UseToolOrchestration]]
Add-StepTransitions $graph $s[[UseDockerRegistryCredential]] $s[[UseToolOrchestration]]

Add-StepTransitions $graph $s[[UseToolOrchestration]] $s[[UseTlsOption]]

Add-StepTransitions $graph $s[[UseExternalStorage]] $s[[ExternalStorageEndpoint]]

Add-StepTransitions $graph $s[[UseExternalStorage]] $s[[UseTlsOption]]
Add-StepTransitions $graph $s[[ExternalStorageBucket]] $s[[UseTlsOption]]
Add-StepTransitions $graph $s[[ExternalStorageTrustCert]] $s[[UseTlsOption]]

Add-StepTransitions $graph $s[[UseTlsOption]] $s[[AuthenticationType]]
Add-StepTransitions $graph $s[[CertsCAPath]] $s[[CertificateIssuerName]],$s[[CertificateIssuerType]],$s[[UseNetworkPolicyOption]]

Add-StepTransitions $graph $s[[UseTlsOption]] $s[[AuthenticationType]]

Add-StepTransitions $graph $s[[UseDefaultCACerts]] $s[[GeneratePwds]]

Add-StepTransitions $graph $s[[GeneratePwds]] $s[[UseDockerRepositoryPrefix]]
Add-StepTransitions $graph $s[[GeneratePwds]] $s[[UseDefaultDockerImages]]
Add-StepTransitions $graph $s[[AdminPassword]] $s[[ToolServiceKey]]
Add-StepTransitions $graph $s[[DatabaseRootPwd]] $s[[DatabaseUserPwd]]
Add-StepTransitions $graph $s[[AdminPassword]] $s[[UseDockerRepositoryPrefix]]
Add-StepTransitions $graph $s[[AdminPassword]] $s[[UseDefaultDockerImages]]
Add-StepTransitions $graph $s[[DatabaseUserPwd]] $s[[UseDockerRepositoryPrefix]]
Add-StepTransitions $graph $s[[DatabaseUserPwd]] $s[[UseDefaultDockerImages]]
Add-StepTransitions $graph $s[[ToolServiceKey]] $s[[UseDockerRepositoryPrefix]]
Add-StepTransitions $graph $s[[ToolServiceKey]] $s[[UseDefaultDockerImages]]
Add-StepTransitions $graph $s[[MinioAdminPassword]] $s[[UseDefaultDockerImages]]

Add-StepTransitions $graph $s[[UseDockerRepositoryPrefix]] $s[[UseDefaultDockerImages]]
Add-StepTransitions $graph $s[[UseDefaultDockerImages]] $s[[DefaultCPU]]
Add-StepTransitions $graph $s[[MariaDBDockerImageVersion]] $s[[DefaultCPU]]
Add-StepTransitions $graph $s[[WebDockerImageVersion]] $s[[DefaultCPU]]

Add-StepTransitions $graph $s[[UseDefaultDockerImages]] $s[[StorageClassName]]
Add-StepTransitions $graph $s[[MariaDBDockerImageVersion]] $s[[StorageClassName]]
Add-StepTransitions $graph $s[[WebDockerImageVersion]] $s[[StorageClassName]]
Add-StepTransitions $graph $s[[WorkflowDockerImageVersion]] $s[[StorageClassName]]

Add-StepTransitions $graph $s[[WebDockerImageVersion]] $s[[ToolOrchestrationDockerImageVersion]]

Add-StepTransitions $graph $s[[WebCPU]] $s[[ToolServiceCPU]]
Add-StepTransitions $graph $s[[WebCPU]] $s[[DefaultMemory]]
Add-StepTransitions $graph $s[[MasterDatabaseCPU]] $s[[ToolServiceCPU]]
Add-StepTransitions $graph $s[[MasterDatabaseCPU]] $s[[DefaultMemory]]
Add-StepTransitions $graph $s[[SubordinateDatabaseCPU]] $s[[DefaultMemory]]
Add-StepTransitions $graph $s[[ToolServiceCPU]] $s[[WorkflowCPU]]
Add-StepTransitions $graph $s[[DefaultCPU]] $s[[DefaultMemory]]

Add-StepTransitions $graph $s[[WebMemory]] $s[[ToolServiceMemory]]
Add-StepTransitions $graph $s[[WebMemory]] $s[[DefaultEphemeralStorage]]
Add-StepTransitions $graph $s[[MasterDatabaseMemory]] $s[[ToolServiceMemory]]
Add-StepTransitions $graph $s[[MasterDatabaseMemory]] $s[[DefaultEphemeralStorage]]
Add-StepTransitions $graph $s[[SubordinateDatabaseMemory]] $s[[DefaultEphemeralStorage]]
Add-StepTransitions $graph $s[[ToolServiceMemory]] $s[[WorkflowMemory]]
Add-StepTransitions $graph $s[[DefaultMemory]] $s[[DefaultEphemeralStorage]]

Add-StepTransitions $graph $s[[WebEphemeralStorage]] $s[[ToolServiceEphemeralStorage]]
Add-StepTransitions $graph $s[[WebEphemeralStorage]] $s[[DefaultVolumeSize]]
Add-StepTransitions $graph $s[[MasterDatabaseEphemeralStorage]] $s[[ToolServiceEphemeralStorage]]
Add-StepTransitions $graph $s[[MasterDatabaseEphemeralStorage]] $s[[DefaultVolumeSize]]
Add-StepTransitions $graph $s[[SubordinateDatabaseEphemeralStorage]] $s[[DefaultVolumeSize]]
Add-StepTransitions $graph $s[[ToolServiceEphemeralStorage]] $s[[WorkflowEphemeralStorage]]
Add-StepTransitions $graph $s[[DefaultEphemeralStorage]] $s[[DefaultVolumeSize]]

Add-StepTransitions $graph $s[[WebVolumeSize]] $s[[MinIOVolumeSize]]
Add-StepTransitions $graph $s[[WebVolumeSize]] $s[[StorageClassName]]
Add-StepTransitions $graph $s[[MasterDatabaseVolumeSize]] $s[[MinIOVolumeSize]]
Add-StepTransitions $graph $s[[MasterDatabaseVolumeSize]] $s[[StorageClassName]]
Add-StepTransitions $graph $s[[SubordinateDatabaseBackupVolumeSize]] $s[[StorageClassName]]
Add-StepTransitions $graph $s[[DefaultVolumeSize]] $s[[StorageClassName]]

Add-StepTransitions $graph $s[[StorageClassName]] $s[[UseNodeSelectors]]
Add-StepTransitions $graph $s[[StorageClassName]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[StorageClassName]] $s[[Finish]]

Add-StepTransitions $graph $s[[AuthCookieSecure]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[AuthCookieSecure]] $s[[Finish]]

Add-StepTransitions $graph $s[[WebNodeSelector]] $s[[ToolServiceNodeSelector]]
Add-StepTransitions $graph $s[[WebNodeSelector]] $s[[UseTolerations]]
Add-StepTransitions $graph $s[[MasterDatabaseNodeSelector]] $s[[ToolServiceNodeSelector]]
Add-StepTransitions $graph $s[[MasterDatabaseNodeSelector]] $s[[UseTolerations]]
Add-StepTransitions $graph $s[[SubordinateDatabaseNodeSelector]] $s[[UseTolerations]]
Add-StepTransitions $graph $s[[ToolServiceNodeSelector]] $s[[WorkflowControllerNodeSelector]]
Add-StepTransitions $graph $s[[UseNodeSelectors]] $s[[UseTolerations]]

Add-StepTransitions $graph $s[[WebTolerations]] $s[[ToolServiceTolerations]]
Add-StepTransitions $graph $s[[WebTolerations]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[WebTolerations]] $s[[Finish]]
Add-StepTransitions $graph $s[[MasterDatabaseTolerations]] $s[[ToolServiceTolerations]]
Add-StepTransitions $graph $s[[MasterDatabaseTolerations]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[MasterDatabaseTolerations]] $s[[Finish]]
Add-StepTransitions $graph $s[[SubordinateDatabaseTolerations]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[SubordinateDatabaseTolerations]] $s[[Finish]]
Add-StepTransitions $graph $s[[ToolServiceTolerations]] $s[[WorkflowControllerTolerations]]

Add-StepTransitions $graph $s[[UseTolerations]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[UseTolerations]] $s[[Finish]]

if ($DebugPreference -eq 'Continue') {
	# Print graph at https://dreampuf.github.io/GraphvizOnline (select 'dot' Engine and use Format 'png-image-element')
	write-host 'digraph G {'
	$s.keys | ForEach-Object { $node = $s[$_]; ($node.getNeighbors() | ForEach-Object { write-host ('{0} -> {1};' -f $node.name,$_) }) }
	write-host '}'
}

try {
	$vStack = Invoke-GuidedSetup 'SRM - Helm Prep Wizard' $s[[Welcome]] ($s[[Finish]],$s[[Abort]])

	Write-StepGraph (Join-Path ($config.workDir ?? './') 'graph.path') $s $vStack
} catch {
	Write-Host "`n`nAn unexpected error occurred: $_`n"
	Write-Host $_.ScriptStackTrace
}