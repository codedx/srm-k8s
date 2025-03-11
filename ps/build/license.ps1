function Get-LicenseSecretName($config) {
	"$($config.releaseName)-license-secret"
}

function Get-ScanFarmLicenseSecretName($config) {
	"$($config.releaseName)-sf-license-secret"
}

function New-ScanFarmLicenseSecret($config) {

	$licenseFiles = @{}

	if ($config.scanFarmLicenseFormatType -eq [ScanFarmLicenseFormatType]::CombinedKeygen) {

		# the combined keygen license file will include available licenses for SCA and SAST
		$licenseFiles['license.json'] = $config.scanFarmCombinedLicenseFile
	} else {

		if (-not [string]::IsNullOrEmpty($config.scanFarmSastLicenseFile)) {
			$licenseFiles['license.dat'] = $config.scanFarmSastLicenseFile
		}

		if (-not [string]::IsNullOrEmpty($config.scanFarmScaLicenseFile)) {
			$licenseFiles['license.json'] = $config.scanFarmScaLicenseFile
		}
	}

	$urlOverride = @{}
	if (-not [string]::IsNullOrEmpty($config.scanFarmScaApiUrlOverride)) {
		$urlOverride['dev-sca-api-url'] = $config.scanFarmScaApiUrlOverride
	}

	New-GenericSecret $config.namespace (Get-ScanFarmLicenseSecretName $config) $urlOverride $licenseFiles `
		-dryRun | Out-File (Get-ScanFarmLicenseSecretK8sPath $config)
}

function New-ScanFarmLicenseConfig($config) {

	New-ScanFarmLicenseSecret $config
    @"
scan-services:
  scan-service:
    licenseSecretName: $(Get-ScanFarmLicenseSecretName $config)
"@ | Out-File (Get-ScanFarmLicenseValuesPath $config)

	@"
scan-services:
  global:
    keygen:
      enabled: $($config.scanFarmLicenseFormatType -eq [ScanFarmLicenseFormatType]::CombinedKeygen ? 'true' : 'false')
"@ | Out-File (Get-ScanFarmLicenseTypeValuesPath $config)
}

function New-LicenseConfig($config) {

	New-GenericSecret $config.namespace (Get-LicenseSecretName $config) -fileKeyValues @{
		"license.lic"=$($config.srmLicenseFile)
	} -dryRun | Out-File (Get-LicenseSecretK8sPath $config)

    @"
web:
  licenseSecret: $(Get-LicenseSecretName $config)
"@ | Out-File (Get-LicenseSecretValuesPath $config)

	if (-not $config.skipScanFarm) {
		New-ScanFarmLicenseConfig $config
	}
}