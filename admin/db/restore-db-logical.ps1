<#PSScriptInfo
.VERSION 1.1.0
.GUID b6b17e02-ecb1-4780-afbc-2128026b7464
.AUTHOR Synopsys
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

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/db/.ps/.restore-db-logical.ps1' @PSBoundParameters