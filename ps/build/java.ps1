function Get-CacertsSecretName($config) {
	"$($config.GetFullName())-web-cacerts-secret"
}

function New-CacertsSecret($config) {

	New-GenericSecret $config.namespace (Get-CacertsSecretName $config) -fileKeyValues @{
		"cacerts"=$(Get-CertsPath $config)
	} -keyValues @{
		"cacerts-password"=$config.caCertsFilePwd
	} -dryRun | Out-File (Get-CertsK8sPath $config)
}

function New-CacertsConfig($config) {

	if ('' -ne $config.clusterCertificateAuthorityCertPath) {
		Import-TrustedCaCerts (Get-CertsPath $config) $config.caCertsFilePwd $config.clusterCertificateAuthorityCertPath
	}

	if ($config.addExtraCertificates) {
		Import-TrustedCaCerts (Get-CertsPath $config) $config.caCertsFilePwd $config.extraTrustedCaCertPaths
	}

	New-CacertsSecret $config

	@"
web:
  cacertsSecret: $(Get-CacertsSecretName $config)
"@ | Out-File (Get-CertsK8sValuesPath $config)
}
