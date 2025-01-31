<#PSScriptInfo
.VERSION 1.3.0
.GUID 0fc2b275-8917-40b1-b05a-87147ed50fb8
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

if (-not $config.isLocked) {
	Write-Host "There is nothing to do; the config file '$configPath' is already unlocked."
	Exit
}

if ([string]::IsNullOrEmpty($configFilePwd)) {
	$configFilePwd = Read-HostSecureText -Prompt 'Enter config file password'
}

$config.Unlock($configFilePwd)
$config | ConvertTo-Json | Out-File $configPath