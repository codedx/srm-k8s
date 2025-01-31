<#PSScriptInfo
.VERSION 1.4.0
.GUID b89cccc3-6d33-4c1e-b78f-91b24d456d28
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

Write-Host 'Loading...' -NoNewline

'../../keyvalue.ps1',
'../../build/protect.ps1',
'../../config.ps1',
'../../steps/step.ps1',
'../../steps/finish.ps1',
'../../steps/image.ps1',
'../../steps/ingress.ps1',
'../../steps/ingress.ps1',
'../../steps/license.ps1',
'../../steps/reg.ps1',
'../../steps/scanfarm.ps1',
'../../steps/scanfarm-cache.ps1',
'../../steps/scanfarm-db.ps1',
'../../steps/scanfarm-storage.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

$config = [Config]::FromJsonFile($configPath)

$workDirectory = $config.workDir
$configDirectory = Split-Path (Resolve-Path $configPath)

# use GetFullPath to normalize directory separators (e.g., convert C:\Users\user/.k8s-srm to C:\Users\user\.k8s-srm)
$workDirectoryFullName   = [IO.Path]::GetFullPath($workDirectory)
$configDirectoryFullName = [IO.Path]::GetFullPath($configDirectory)
$isConfigInWorkDirectory = $workDirectoryFullName -eq $configDirectoryFullName

if (-not $isConfigInWorkDirectory) {
	# wizard writes the updated config.json to the work directory
	Write-Error "Unable to continue because your config.json file must reside in your work directory. Move your config.json file from '$configDirectoryFullName' to '$workDirectoryFullName' before retrying."
}

if ($config.isLocked) {

	if ([string]::IsNullOrEmpty($configFilePwd)) {
		$configFilePwd = Read-HostSecureText -Prompt 'Enter config file password'
	}

	$config.Unlock($configFilePwd)
}

# make a backup copy of the config file
Copy-Item $configPath ([IO.Path]::ChangeExtension($configPath, '.json.bak')) -Force

$graph = New-Object Graph($true)

$s = @{}
[AbortScanFarm],
[CertManagerIssuer],
[DockerRepositoryPrefix],
[DockerRegistryHost],
[DockerRegistryPwd],
[DockerRegistryUser],
[DockerImagePullSecret],
[Finish],
[IngressCertificateArn],
[IngressClassName],
[IngressHostname],
[IngressKind],
[IngressTLS],
[IngressTLSSecretName],
[Lock],
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
[ScanFarmTlsRemoval],
[ScanFarmType],
[RepoUsername],
[RepoPassword],
[UseDockerRegistry],
[UseDockerRegistryCredential],
[UseDockerRepositoryPrefix],
[UseScanFarm],
[WelcomeScanFarm] | ForEach-Object {
	Write-Debug "Creating $_ object..."
	$s[$_] = new-object -type $_ -args $config
	Add-Step $graph $s[$_]
}

Add-StepTransitions $graph $s[[WelcomeScanFarm]] $s[[UseScanFarm]],$s[[AbortScanFarm]]

Add-StepTransitions $graph $s[[WelcomeScanFarm]] $s[[UseScanFarm]],$s[[RepoUsername]],$s[[RepoPassword]],$s[[ScanFarmType]],$s[[ScanFarmSastLicense]],$s[[ScanFarmScaLicense]],
	$s[[ScanFarmDatabaseHost]],$s[[ScanFarmDatabasePort]],$s[[ScanFarmDatabaseUsername]],$s[[ScanFarmDatabasePwd]],
	$s[[ScanFarmDatabaseTls]],$s[[ScanFarmDatabaseCert]],$s[[ScanFarmScanServiceDatabaseName]],$s[[ScanFarmStorageServiceDatabaseName]],
	$s[[ScanFarmRedisRequirements]],$s[[ScanFarmRedisHost]],$s[[ScanFarmRedisPort]],$s[[ScanFarmRedisDatabase]],
	$s[[ScanFarmRedisAuth]],$s[[ScanFarmRedisPassword]],$s[[ScanFarmRedisTls]],$s[[ScanFarmRedisCert]],
	$s[[ScanFarmStorage]],$s[[ScanFarmStorageBucketName]],$s[[ScanFarmCacheBucketName]]

Add-StepTransitions $graph $s[[ScanFarmDatabaseTls]] $s[[ScanFarmScanServiceDatabaseName]]
Add-StepTransitions $graph $s[[ScanFarmRedisAuth]] $s[[ScanFarmRedisTls]]
Add-StepTransitions $graph $s[[ScanFarmRedisTls]] $s[[ScanFarmStorage]]

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

Add-StepTransitions $graph $s[[DockerRegistryHost]] $s[[UseDockerRegistryCredential]],$s[[DockerImagePullSecret]],
	$s[[DockerRegistryUser]],$s[[DockerRegistryPwd]],$s[[UseDockerRepositoryPrefix]],$s[[DockerRepositoryPrefix]],
	$s[[IngressKind]]

Add-StepTransitions $graph $s[[UseDockerRegistryCredential]] $s[[UseDockerRepositoryPrefix]]
Add-StepTransitions $graph $s[[UseDockerRepositoryPrefix]] $s[[IngressKind]]

Add-StepTransitions $graph $s[[IngressKind]] $s[[IngressClassName]],$s[[IngressTLS]],$s[[CertManagerIssuer]],$s[[IngressHostname]]
Add-StepTransitions $graph $s[[IngressTLS]] $s[[IngressTLSSecretName]],$s[[IngressHostname]]
Add-StepTransitions $graph $s[[IngressTLS]] $s[[IngressHostname]]

Add-StepTransitions $graph $s[[IngressHostname]] $s[[ScanFarmTlsRemoval]],$s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[IngressHostname]] $s[[Lock]],$s[[Finish]]
Add-StepTransitions $graph $s[[ScanFarmTlsRemoval]] $s[[Finish]]
Add-StepTransitions $graph $s[[IngressHostname]] $s[[Finish]]

if ($DebugPreference -eq 'Continue') {
	# Print graph at https://dreampuf.github.io/GraphvizOnline (select 'dot' Engine and use Format 'png-image-element')
	write-host 'digraph G {'
	$s.keys | ForEach-Object { $node = $s[$_]; ($node.getNeighbors() | ForEach-Object { write-host ('{0} -> {1};' -f $node.name,$_) }) }
	write-host '}'
}

try {
	$vStack = Invoke-GuidedSetup 'SRM - Add Scan Farm Wizard' $s[[WelcomeScanFarm]] ($s[[Finish]],$s[[AbortScanFarm]])
	Write-StepGraph (Join-Path ($config.workDir ?? './') 'graph.wiz.sf.path') $s $vStack
} catch {
	Write-Host "`n`nAn unexpected error occurred: $_`n"
	Write-Host $_.ScriptStackTrace
}