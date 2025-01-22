function Get-SigRepoSecretName($config) {
	"$($config.releaseName)-sig-repo-secret"
}

function New-SigRepoSecret($config) {

	New-GenericSecret $config.namespace (Get-SigRepoSecretName $config) -keyValues @{
		"username"=$config.repoUsername
		"password"=$config.repoPwd
	} -dryRun | Out-File (Get-SigRepoSecretK8sPath $config)
}

function New-ScanFarmInternalStorageConfig($config) {

	@"
scan-services:
  storage-service:
    endpoint:
      internal:
        url: $($config.scanFarmStorageInClusterUrl)
"@ | Out-File (Get-ScanFarmInternalUrlValuesPath $config)
}

function New-ScanFarmExternalProxiedStorageConfig($config) {

  $externalWebSvcProtocol = "http"
	if ($config.ingressTlsSecretName) {
		$externalWebSvcProtocol = "https"
	}
  $externalWebSvcUrl = "$externalWebSvcProtocol`://$($config.ingressHostname)"

	@"
scan-services:
  storage-service:
    endpoint:
      external:
        proxyPath: '$($config.scanFarmStorageContextPath)'
        url: $externalWebSvcUrl
"@ | Out-File (Get-ScanFarmStorageExternalProxiedUrlValuesPath $config)
}

function New-ScanFarmExternalStorageConfig($config) {

	@"
scan-services:
  storage-service:
    endpoint:
      external:
        url: $($config.scanFarmStorageExternalUrl)
"@ | Out-File (Get-ScanFarmStorageExternalUrlValuesPath $config)
}

function New-ScanFarmConfig($config) {

  New-SigRepoSecret $config
	New-ScanFarmDatabaseConfig $config
	New-ScanFarmCacheConfig $config
	New-ScanFarmStorageConfig $config

	$webSvcName = $config.GetWebServiceName()

  $webSvcProtocol = "http"
  if (-not $config.skipTLS) {
    $webSvcProtocol = "https"
  }

	$webSvcUrl = "$webSvcProtocol`://$webSvcName`:$($config.webServicePortNumber)/srm"

	@"
features:
  scanfarm: true
scan-services:
  cache-service:
    javaOpts: "-Dserver.ssl.enabled-protocols=TLSv1.2,TLSv1.3 -Dcom.synopsys.coverity.cache.srm.secure=false"
  scan-service:
    tools:
      sync:
        enabled: true
        existingSecret: $(Get-SigRepoSecretName $config)
  srm:
    url: $webSvcUrl
    codesight:
      url: https://codesight.blackduck.com
"@ | Out-File (Get-ScanFarmValuesPath $config)

	if ($config.scanFarmStorageHasInClusterUrl) {
		New-ScanFarmInternalStorageConfig $config
	}
}