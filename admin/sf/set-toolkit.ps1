<#PSScriptInfo
.VERSION 1.2.0
.GUID 455ac2e7-650b-420e-9a7a-3868da844bc4
.AUTHOR Black Duck
#>

<# 
.DESCRIPTION 
This script lets you load a SAST toolkit without using the tool-sync capability of the scan service. It assumes
that your scan service's tool-sync capability has been disabled with the following Helm configuration, which
should be added to your srm-extra-props.yaml file:

scan-services:
  scan-service:
    tools:
      sync:
        enabled: false
#>

param (
	[string] $srmHostname,
	[string] $srmAdminApiKey,
	[string] $repoUsername,
	[string] $repoPwd,
	[string] $srmNamespace = 'srm',
	[string] $tool = 'coverity',
	[string] $toolVersion = '2024.12.0',
	[int]    $maxUploadPartSize = 500*(1024*1024),
	[string] $srmPath = '/srm'
)

& "$PSScriptRoot/../../.start.ps1" -startScriptPath 'admin/sf/.ps/.set-toolkit.ps1' @PSBoundParameters
