function Get-DatabasePropsSecretName($config) {
	"$($config.releaseName)-db-props-secret"
}

function Get-DatabaseMariaDBSecretName($config) {
	"$($config.releaseName)-db-cred-secret"
}

function New-DatabasePropsFile($config) {

	$dbUser = 'codedx'
	$dbPwd = $config.srmDatabaseUserPwd

	if ($config.skipDatabase) {
		$dbUser = $config.externalDatabaseUser
		$dbPwd = $config.externalDatabasePwd
	}
	
	$dbPropsPathConfigContent = "swa.db.user = """"""$dbUser"""""""
	if ($config.externalDatabaseAuthType -eq [ExternalDatabaseAuthType]::Password) {
		$dbPropsPathConfigContent += "`nswa.db.password = """"""$dbPwd"""""""
	}
	$dbPropsPathConfigContent | Out-File (Get-DatabasePropsPath $config)
}

function New-DatabasePropsSecret($config) {

	New-DatabasePropsFile $config
	New-GenericSecret $config.namespace (Get-DatabasePropsSecretName $config) -fileKeyValues @{
		"db.props"=$(Get-DatabasePropsPath $config)
	} -dryRun | Out-File (Get-DatabasePropsK8sPath $config)
}

function New-DatabaseMariaDBSecret($config) {

	$dbPwds = @{
		"mariadb-root-password"=$($config.mariadbRootPwd)
		"mariadb-password"=$($config.srmDatabaseUserPwd)
	}
	if ($config.dbSlaveReplicaCount -gt 0) {
		$dbPwds["mariadb-replication-password"]=$($config.mariadbReplicatorPwd)
	}
	New-GenericSecret $config.namespace (Get-DatabaseMariaDBSecretName $config) -keyValues $dbPwds -dryRun | Out-File (Get-DatabaseMariaDbK8sPath $config)
}

function New-ExternalDatabaseConfig($config) {

	New-DatabasePropsSecret $config

	$urlOption = ''
	if (-not $config.externalDatabaseSkipTls) {
		$urlOption = '?useSSL=true&requireSSL=true'
	}

	@"
features:
  mariadb: false
web:
  database:
    credentialSecret: $(Get-DatabasePropsSecretName $config)
    externalDbUrl: jdbc:mysql://$($config.externalDatabaseHost):$($config.externalDatabasePort)/$($config.externalDatabaseName)$urlOption
"@ | Out-File (Get-DatabaseCredentialValuesPath $config)

	if ($config.externalDatabaseAuthType -eq [ExternalDatabaseAuthType]::RdsIam) {
		@"
web:
  database:
    rdsAuth:
      enabled: true
"@ | Out-File (Get-DatabaseRdsValuesPath $config)
	}

	if ($config.externalDatabaseTrustCert) {
		Import-TrustedCaCert (Get-CertsPath $config) $config.caCertsFilePwd $config.externalDatabaseServerCert
	}
}

function New-InternalDatabaseConfig($config) {

	@"
mariadb:
  replication:
    enabled: $(ConvertTo-Json ($config.dbSlaveReplicaCount -gt 0))
  slave:
    replicas: $($config.dbSlaveReplicaCount)
"@ | Out-File (Get-DatabaseReplicationValuesPath $config)

	if ($config.useGeneratedPwds) {
		return
	}

	New-DatabasePropsSecret $config
	New-DatabaseMariaDBSecret $config

	@"
web:
  database:
    credentialSecret: $(Get-DatabasePropsSecretName $config)
mariadb:
  existingSecret: $(Get-DatabaseMariaDBSecretName $config)
"@ | Out-File (Get-DatabaseCredentialValuesPath $config)
}

function New-DatabaseConfig($config) {

	if ($config.skipDatabase) {
		New-ExternalDatabaseConfig $config
	} else {
		New-InternalDatabaseConfig $config
	}
}
