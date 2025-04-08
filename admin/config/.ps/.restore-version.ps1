<#PSScriptInfo
.VERSION 1.4.0
.GUID 4504dc63-bd21-46b8-994f-75f06d2766a0
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }
param (
	[Parameter(Mandatory=$true)][string] $configPath
)

$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

'../../../ps/keyvalue.ps1',
'../../../ps/config.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

function Get-PriorConfigVersion([Management.Automation.SemanticVersion] $version) {

	if ($version.Patch -gt 0) {
		new-object Management.Automation.SemanticVersion($version.Major, $version.Minor, ($version.Patch - 1))
	} elseif ($version.Minor -gt 0) {
		new-object Management.Automation.SemanticVersion($version.Major, ($version.Minor - 1), $version.Patch)
	} elseif ($version.Major -gt 1) { # min Major version for config.json is effectively 1.0 (technically, it's a blank value)
		new-object Management.Automation.SemanticVersion(($version.Major - 1), $version.Minor, $version.Patch)
	} else {
		$null
	}
}

Write-Host "Loading $configPath..." -NoNewline
$configDir = Split-Path $configPath
if ('' -eq $configDir) {
	$configDir = (Get-Location).Path
}
$config = [Config]::FromJsonFile($configPath)
Write-Host "in-memory config.json has version $($config.configVersion)"

if ('' -eq $config.configVersion) {
	Write-Host 'Unable to downgrade your config.json file because it appears to be at version 1.0'
	exit
}

$thisVersion = new-object Management.Automation.SemanticVersion($config.configVersion)

$priorVersion = Get-PriorConfigVersion $thisVersion
while ($null -ne $priorVersion) {

	$priorVersionLabel = $priorVersion.toString()
	$continueRollback = Read-HostChoice `
		"`nDo you want to rollback to config.json version $priorVersionLabel`?" `
		 ([tuple]::Create('Yes', "Revert config.json to version $priorVersionLabel"), 
		  [tuple]::Create('No',  'Stop rollback process'))

	if (0 -ne $continueRollback) {
		exit
	}
	Write-Host "Downgrading to $priorVersion..."

	$thisVersionLabel = $thisVersion.toString()

	# create a backup
	$config | ConvertTo-Json | Out-File -Force -LiteralPath (Join-Path $configDir "config.json.$thisVersionLabel.bak")

	$fieldsToRemove = @()
	$fieldsToRename = @()

	switch ($priorVersionLabel) {

		('1.7.0') {
			# 1.8 -> 1.7
			$fieldsToRemove += 'externalDatabaseAuthType'
			$fieldsToRemove += 'skipWebServiceAccountCreate'
			$fieldsToRemove += 'webServiceAccountName'
			break
		}
		('1.6.0') {
			# 1.7 -> 1.6
			$fieldsToRemove += 'scanFarmCombinedLicenseFile'
			$fieldsToRemove += 'scanFarmLicenseFormatType'
			break
		}
		('1.5.0') {
			# 1.6 -> 1.5
			$fieldsToRename += @([Tuple]::Create('repoUsername', 'sigRepoUsername'))
			$fieldsToRename += @([Tuple]::Create('repoPwd', 'sigRepoPwd'))
			break
		}
		('1.4.0') {
			# 1.5 -> 1.4
			$fieldsToRemove += 'authCookieSecure'
			break
		}
		('1.3.0') {
			# 1.4 -> 1.3
			$fieldsToRemove += 'workflowStorageType'
			$fieldsToRemove += 'serviceAccountToolService'
			$fieldsToRemove += 'serviceAccountWorkflow'
			break
		}
		('1.2.0') {
			# 1.3 -> 1.2
			$fieldsToRemove += 'systemSize'
			break
		}
		('1.1.0') {
			# 1.2 -> 1.1
			$fieldsToRemove += 'scanFarmStorageIsProxied'
			$fieldsToRemove += 'scanFarmStorageContextPath'
			$fieldsToRemove += 'scanFarmStorageExternalUrl'
			break
		}
		('1.0.0') {
			# 1.1 -> 1.0
			$fieldsToRemove += 'salts'
			$fieldsToRemove += 'isLocked'
			break
		}
		default {
			Write-ErrorMessageAndExit "Unable to downgrade to version $priorVersionLabel"
		}
	}

	$fieldsToRename | ForEach-Object {
		Write-Host "  Renaming field $($_.Item1) to $($_.Item2)..."
		$config = ([Config]::RenameJsonField($config, $_.Item1, $_.Item2))
	}
	$fieldsToRemove | ForEach-Object {
		Write-Host "  Removing field $_..."
		$config = ([Config]::RemoveJsonField($config, $_))
	}

	$config.configVersion = "$($priorVersion.Major).$($priorVersion.Minor)"

	$thisVersion = new-object Management.Automation.SemanticVersion($config.configVersion)
	$thisversionlabel = $thisVersion.toString()

	# save this version
	$config | ConvertTo-Json | Out-File -Force -LiteralPath (Join-Path $configDir 'config.json')

	$thisVersion = new-object Management.Automation.SemanticVersion($config.configVersion)
	$priorVersion = Get-PriorConfigVersion $priorVersion
}


