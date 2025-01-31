<#PSScriptInfo
.VERSION 1.2.0
.GUID 0ef2e57d-85d5-43e5-8ba5-b95e4d69c1af
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
.DESCRIPTION Starts the SRM Helm Prep Wizard after conditionally helping with module installation.
#>
param (
	[string] $previousConfigPath
)
& "$PSScriptRoot/.start.ps1" -startScriptPath '.helm-prep-wizard.ps1' @PSBoundParameters
