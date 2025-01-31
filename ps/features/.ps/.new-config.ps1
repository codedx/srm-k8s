<#PSScriptInfo
.VERSION 1.2.0
.GUID b38bfed0-123d-4a7a-a7f6-a7b6ed6ecdf5
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

Write-Host 'Loading...' -NoNewline

'../../keyvalue.ps1',
'../../config.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

$choices = @(
	[tuple]::create('Quick Start - SRM &Core Feature', 'I used the Core Quick Start installation method')
	[tuple]::create('Quick Start - SRM with &Tool Orchestration Feature', 'I used the Tool Orchestration Quick Start installation method')
	[tuple]::create('&Full Installation', 'I used the Full Installation method')
)
$deploymentTypeQuestion =  new-object MultipleChoiceQuestion("How did you deploy SRM?", $choices, 0)

$deploymentTypeQuestion.prompt()
if ($deploymentTypeQuestion.choice -eq 2) {
	Write-Host 'This script is not applicable because it helps you generate a config.json for a deployment created using one of the Quick Start methods.' -ForegroundColor Red -BackgroundColor Black
	return
}

$namespaceQuestion = new-object Question('What Kubernetes namespace did you use?')
$namespaceQuestion.allowEmptyResponse = $true
$namespaceQuestion.emptyResponseLabel = 'Accept Default (srm)'
$namespaceQuestion.Prompt()

$releaseNameQuestion = new-object Question('What Helm release name did you use?')
$releaseNameQuestion.allowEmptyResponse = $true
$releaseNameQuestion.emptyResponseLabel = 'Accept Default (srm)'
$releaseNameQuestion.Prompt()

$workDirectoryQuestion = new-object PathQuestion('Specify a directory to use as your "working" directory (e.g., /home/user/.k8s-srm)', $true, $false)
$workDirectoryQuestion.Prompt()

$licenseQuestion = new-object PathQuestion('Specify the path to your SRM license file', $false, $false)
$licenseQuestion.Prompt()

$config = new-object Config

$config.namespace = $namespaceQuestion.GetResponse('srm')
$config.releaseName = $releaseNameQuestion.GetResponse('srm')
$config.workDir = (Resolve-Path $workDirectoryQuestion.response).Path
$config.useGeneratedPwds = $true
$config.srmLicenseFile = $licenseQuestion.response
$config.skipToolOrchestration = $deploymentTypeQuestion.choice -eq 0

# the next section sets config.json properties that match the default values.yaml
$config.webServiceType = 'ClusterIP'
$config.dbSlaveReplicaCount = 0 # differs from values.yaml, but sets mariadb.replication.enabled=false
$config.skipIngressEnabled = $true
$config.skipNetworkPolicies = $true
$config.skipScanFarm = $true
$config.skipTls = $true

$configJsonPath = Join-Path $config.workDir 'config.json'
$config | ConvertTo-Json | Out-File $configJsonPath

$runSetupScriptPath = Join-Path $config.workDir 'run-helm-prep.ps1'
$helmPrepScriptPath = (Resolve-Path (Join-Path $PSScriptRoot '../../helm-prep.ps1')).Path

Write-Host "`nWriting $runSetupScriptPath..."
"& '$helmPrepScriptPath' -configPath '$configJsonPath'" | Out-File $runSetupScriptPath

Write-Host "`nGenerate/re-generate helm command and required resource YAMLs by running: `n  pwsh ""$runSetupScriptPath""`n"
