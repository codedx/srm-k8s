<#PSScriptInfo
.VERSION 1.3.0
.GUID 48b88fb6-3c18-4a9f-9f09-c0f777217949
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

'../../../ps/keyvalue.ps1',
'../../../ps/build/protect.ps1',
'../../../ps/config.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

$config = [Config]::FromJsonFile($configPath)

if ($config.isLocked) {
	Write-Error "Config file '$configPath' is already locked. To re-lock, unlock it first."
}

# avoid locking a config.json file that will not encrypt any field values
if (-not ($config.ShouldLock())) {
	Write-Host 'There is nothing to do; the current field values in the config file do not require locking.'
	Exit
}

if ([string]::IsNullOrEmpty($configFilePwd)) {

	do {
		$configFilePwd = Read-HostSecureText -Prompt 'Enter config file password'
	} while ($configFilePwd -ne (Read-HostSecureText -Prompt 'Confirm config file password')) 
}

$config.Lock($configFilePwd)
$config | ConvertTo-Json | Out-File $configPath