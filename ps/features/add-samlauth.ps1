<#PSScriptInfo
.VERSION 1.0.0
.GUID f828b1ad-f749-4e3d-8d7f-f2187f12d473
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'ps/features/.ps/.add-samlauth.ps1' @PSBoundParameters