<#PSScriptInfo
.VERSION 1.2.0
.GUID 503f30e0-edc9-4ae7-abed-62da0a01c57e
.AUTHOR Black Duck
.COPYRIGHT Copyright 2025 Black Duck Software, Inc. All rights reserved.
.DESCRIPTION 
If you are logged in to both the Black Duck container registry and your
private registry, you can use the script below to pull, tag, and push all
Black Duck container images associated with the Software Risk Manager
chart version in this repository.
#>
param (
	[Parameter(Mandatory=$true)][string] $myPrivateRegistryPrefix
)

$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tomcat:v2025.6.4',
'codedx/codedx-tools:v2025.6.4',
'codedx/codedx-prepare:v2.14.0',
'codedx/codedx-newanalysis:v2.14.0',
'codedx/codedx-results:v2.14.0',
'codedx/codedx-tool-service:v2.14.0',
'codedx/codedx-cleanup:v2.14.0',
'codedx/codedx-mariadb:v1.38.0',
'bitnami/minio:2025.7.23-debian-12-r0',
'argoproj/workflow-controller:v3.6.10',
'argoproj/argoexec:v3.6.10',
'cache-service:2024.12.0',
'common-infra:2024.12.0',
'scan-service:2024.12.0',
'scan-service-migration:2024.12.0',
'storage-service:2024.12.0',
'storage-service-migration:2024.12.0',
'job-runner:2024.12.0' | ForEach-Object {

	docker pull "repo.blackduck.com/containers/$_"
	if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

	docker tag "repo.blackduck.com/containers/$_" "$myPrivateRegistryPrefix$_"
	if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

	docker push "$myPrivateRegistryPrefix$_"
	if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
