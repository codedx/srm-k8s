<#PSScriptInfo
.VERSION 1.3.0
.GUID 57d15498-e495-414e-8fa0-8f28de12cebc
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

# files load into the latest format
$config = [Config]::FromJsonFile($configPath)

if ($config.isLocked) {

	if ([string]::IsNullOrEmpty($configFilePwd)) {
		$configFilePwd = Read-HostSecureText -Prompt 'Enter config file password'
	}
	
	# if caller does not know the file password, block file conversion
	try {
		$config.Unlock($configFilePwd);
	} catch {
		Write-Error "Unable to change the file format because you specified an invalid password for $configPath."
	}

	# reload the original file to keep the same content
	$config = [Config]::FromJsonFile($configPath)
}

# make a backup copy of the config file
Copy-Item $configPath ([IO.Path]::ChangeExtension($configPath, '.json.bak')) -Force

$config | ConvertTo-Json | Out-File $configPath