<#PSScriptInfo
.VERSION 1.3.0
.GUID b6b17e02-ecb1-4780-afbc-2128026b7464
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

<# 
.DESCRIPTION 
This script automates the process of restoring the MariaDB master database with
a logical backup generated by mysqldump:

mysqldump --host=127.0.0.1 --port=3306 --user=root -p codedx > /bitnami/mariadb/dump-codedx.sql

Note: This does not work with a physical backup generated with mariabackup.
#>

param (
	[string] $backupToRestore, # logical backup file (dump.sql) or tar gzipped file (dump.tgz containing a dump.sql file)
	[string] $rootPwd,
	[string] $replicationPwd,
	[string] $namespace = 'srm',
	[string] $releaseName = 'srm',
	[int]    $waitSeconds = 600,
	[switch] $skipWebRestart
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

$global:PSNativeCommandArgumentPassing='Legacy'

function New-DatabaseFromLogicalBackup([string] $namespace, 
	[string] $podName,
	[string] $containerName,
	[string] $rootPwd,
	[string] $databaseName,
	[string] $databaseDump,
	[switch] $skipDropDatabase) {

	if (-not $skipDropDatabase) {
		Remove-Database $namespace $podName $containerName $rootPwd $databaseName 
	}

	$cmd = "CREATE DATABASE $databaseName"

	kubectl -n $namespace exec -c $containerName $podName -- mysql -uroot --password=$rootPwd -e $cmd
	if (0 -ne $LASTEXITCODE) {
		Write-Error "Unable to create database, kubectl exited with exit code $LASTEXITCODE."
	}

	if (-not (Test-Path $databaseDump -PathType Leaf)) {
		Write-Error "Unable to find database dump file at $databaseDump."
	}

	$databaseDumpFilename = Split-Path $databaseDump -Leaf

	$importPath = "/bitnami/mariadb/$databaseDumpFilename"
	Copy-K8sItem $namespace $databaseDump $podName $containerName $importPath

	$databaseDumpFileExtension = [IO.Path]::GetExtension($databaseDumpFilename)
	if ($databaseDumpFileExtension -eq '.tgz') {

		# a tar gzip file should expand to a file of the same name with a .sql extension
		# for example, tar cvzf dump.tgz dump.sql
		kubectl -n $namespace exec -c $containerName $podName -- tar xvf $importPath -C '/bitnami/mariadb'
		if (0 -ne $LASTEXITCODE) {
			Write-Error "Unable to extract $importPath, kubectl exited with exit code $LASTEXITCODE."
		}
		$importPath = [IO.Path]::ChangeExtension($importPath, '.sql')
	}

	kubectl -n $namespace exec -c $containerName $podName -- bash -c "mysql -uroot --password=""$rootPwd"" $databaseName < $importPath"
	if (0 -ne $LASTEXITCODE) {
		Write-Error "Unable to import database dump, kubectl exited with exit code $LASTEXITCODE."
	}
}

function Get-HelmValuesAll([string] $namespace, [string] $releaseName) {

	$values = helm -n $namespace get values $releaseName -a -o json
	if ($LASTEXITCODE -ne 0) {
		throw "Unable to get release values, helm exited with code $LASTEXITCODE."
	}
	ConvertFrom-Json $values
}

if (-not (Test-HelmRelease $namespace $releaseName)) {
	Write-Error "Unable to find Helm release named $releaseName in namespace $namespace."
}

$deployment = "$(Get-HelmChartFullnameEquals $releaseName 'srm')-web"

$dbFullChartName = Get-HelmChartFullnameContains $releaseName 'mariadb'
$statefulSetMariaDBMaster = "$dbFullChartName-master"
$statefulSetMariaDBSlave = "$dbFullChartName-slave"

$values = Get-HelmValuesAll $namespace $releaseName
$statefulSetMariaDBSlaveCount = $values.mariadb.slave.replicas
if (-not $values.mariadb.replication.enabled) {
	$statefulSetMariaDBSlaveCount = 0
	$statefulSetMariaDBMaster = $dbFullChartName
	$statefulSetMariaDBSlave = ''
}

$mariaDbMasterServiceName = $dbFullChartName

if (-not (Test-Deployment $namespace $deployment)) {
	Write-Error "Unable to find Deployment named $deployment in namespace $namespace."
}

if (-not (Test-StatefulSet $namespace $statefulSetMariaDBMaster)) {
	Write-Error "Unable to find StatefulSet named $statefulSetMariaDBMaster in namespace $namespace."
}

if ($statefulSetMariaDBSlaveCount -ne 0 -and (-not (Test-StatefulSet $namespace $statefulSetMariaDBSlave))) {
	Write-Error "Unable to find StatefulSet named $statefulSetMariaDBSlave in namespace $namespace."
}

# identify the MariaDB password K8s secret resource name
$mariaDbSecretName = "$releaseName-mariadb-default-secret"
if ($null -ne $values.mariadb.existingSecret) {
	$mariaDbSecretName = $values.mariadb.existingSecret
}

if (-not (Test-Secret $namespace $mariaDbSecretName)) {
	# it could be a default DB resource
	Write-Error "Unable to find Secret named $mariaDbSecretName in namespace $namespace."
}

if (-not (Test-Service $namespace $mariaDbMasterServiceName)) {
	Write-Error "Unable to find Service named $mariaDbMasterServiceName in namespace $namespace."
}

$mariaDBServiceAccount = Get-ServiceAccountName $namespace 'statefulset' $statefulSetMariaDBMaster

Write-Host @"

Using the following configuration:

Deployment Name: $deployment
MariaDB Master StatefulSet Name: $statefulSetMariaDBMaster
MariaDB Slave StatefulSet Name: $statefulSetMariaDBSlave
MariaDB Slave Replica Count: $statefulSetMariaDBSlaveCount
MariaDB Secret Name: $mariaDbSecretName
MariaDB Master Service Name: $mariaDbMasterServiceName
MariaDB Service Account: $mariaDBServiceAccount
"@

if ($backupToRestore -eq '') { 
	$backupToRestore = Read-HostText 'Enter the db backup to restore (backup.sql)' 1 
}

if (-not (Test-Path $backupToRestore -PathType Leaf)) {
	Write-Error "The '$backupToRestore' file does not exist."
}
if ('.sql','.tgz' -notcontains ([io.path]::GetExtension($backupToRestore))) {
	Write-Error "The '$backupToRestore' file does not have a .sql or .tgz file extension."
}
if ($backupToRestore.Contains(":")) {
	Write-Error "Unable to continue because the '$backupToRestore' path contains a colon that will disrupt a required kubectl cp command - specify an alternate, relative path instead."
}

if ($rootPwd -eq '') { 
	$rootPwd = Read-HostSecureText 'Enter the password for the MariaDB root user' 1 
}

if ($replicationPwd -eq '') {
	$replicationPwd = Read-HostSecureText 'Enter the password for the MariaDB replication user' 1 
}

Write-Verbose 'Restarting database...'
& (join-path $PSScriptRoot '.restart-db.ps1') -namespace $namespace -releaseName $releaseName -waitSeconds $waitSeconds -skipWebRestart

Write-Verbose 'Searching for MariaDB slave pods...'
$podFullNamesSlaves = kubectl -n $namespace get pod -l component=slave -o name
if (0 -ne $LASTEXITCODE) {
	Write-Error "Unable to fetch slave pods, kubectl exited with exit code $LASTEXITCODE."
}

$podNamesSlaves = @()
$podFullNamesSlaves | ForEach-Object {

	$podName = $_ -replace 'pod/',''
	$podNamesSlaves = $podNamesSlaves + $podName
}

Write-Verbose 'Searching for web pod...'
$podName = kubectl -n $namespace get pod -l component=web -o name
if (0 -ne $LASTEXITCODE) {
	Write-Error "Unable to find web pod, kubectl exited with exit code $LASTEXITCODE."
}
$podName = $podName -replace 'pod/',''

Write-Verbose 'Searching for MariaDB master pod...'
$podNameMaster = kubectl -n $namespace get pod -l component=master -o name
if (0 -ne $LASTEXITCODE) {
	Write-Error "Unable to find MariaDB master pod, kubectl exited with exit code $LASTEXITCODE."
}

if ([string]::IsNullOrEmpty($podNameMaster)) {
	Write-Error "Unable to find primary database pod. Is it running?"
}
$podNameMaster = $podNameMaster -replace 'pod/',''

Write-Verbose "Stopping deployment named $deployment..."
Set-DeploymentReplicas  $namespace $deployment 0 $waitSeconds

Write-Verbose 'Stopping slave database instances...'
$podNamesSlaves | ForEach-Object {
	Write-Verbose "Stopping slave named $_..."
	Stop-SlaveDB $namespace $_ 'mariadb' $rootPwd
}

Write-Verbose "Restoring database backup on pod $podNameMaster..."
New-DatabaseFromLogicalBackup $namespace $podNameMaster 'mariadb' $rootPwd 'codedx' $backupToRestore
$podNamesSlaves | ForEach-Object {
	Write-Verbose "Restoring database backup on pod $_..."
	New-DatabaseFromLogicalBackup $namespace $_ 'mariadb' $rootPwd 'codedx' $backupToRestore
}

Write-Verbose "Starting $statefulSetMariaDBMaster statefulset replica..."
Set-StatefulSetReplicas $namespace $statefulSetMariaDBMaster 1 $waitSeconds

if ($statefulSetMariaDBSlaveCount -ne 0) {

	Write-Verbose "Starting $statefulSetMariaDBSlave statefulset replica(s)..."
	Set-StatefulSetReplicas $namespace $statefulSetMariaDBSlave $statefulSetMariaDBSlaveCount $waitSeconds

	Write-Verbose 'Resetting master database...'
	$filePos = Get-MasterFilePosAfterReset $namespace 'mariadb' $podNameMaster $rootPwd

	Write-Verbose 'Connecting slave database(s)...'
	$podNamesSlaves | ForEach-Object {
		Write-Verbose "Restoring slave database pod $_..."
		Stop-SlaveDB $namespace $_ 'mariadb' $rootPwd
		Start-SlaveDB $namespace $_ 'mariadb' 'replicator' $replicationPwd $rootPwd $mariaDbMasterServiceName $filePos
	}
}

if ($skipWebRestart) {
	Write-Verbose "Skipping Restart..."
	Write-Verbose " To restart, run: kubectl -n $namespace scale --replicas=1 deployment/$deployment"
} else {
	Write-Verbose "Starting deployment named $deployment..."
	Set-DeploymentReplicas  $namespace $deployment 1 $waitSeconds
}

Write-Host 'Done'
