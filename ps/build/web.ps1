function New-WebSecretConfig($config) {

	$webSecretName = "$($config.releaseName)-web-secret"
	New-GenericSecret $config.namespace $webSecretName -keyValues @{
		'admin-password' = $config.adminPwd
	} -dryRun | Out-File (Get-WebK8sPath $config)

	@"
web:
  webSecret: $webSecretName
"@ | Out-File (Get-WebValuesPath $config)
}

function New-ServiceAccountConfig($config) {

	@"
web:
  serviceAccount:
    create: $((!$config.skipWebServiceAccountCreate).ToString().ToLower())
    name: "$($config.webServiceAccountName)"
"@ | Out-File (Get-WebServiceAccountValuesPath $config)
}