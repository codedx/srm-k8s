<#PSScriptInfo
.VERSION 1.23.0
.GUID 31739033-88f1-425d-be17-ed5ad608d005
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

<# 
.DESCRIPTION 
This script generates Flux v2 artifacts from the output of the Helm Prep Script.
#>

[CmdletBinding(DefaultParameterSetName = 'Helm')]
param (
	[Parameter(ParameterSetName = 'Helm', Position = 0)]
	[Parameter(ParameterSetName = 'Git', Position = 0)]
	[string]   $workDir = "$HOME/.k8s-srm",

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string] $namespace,

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string] $releaseName,

	[Parameter(ParameterSetName = 'Helm')]
	[string]   $helmChartRepoUrl = 'https://codedx.github.io/srm-k8s',
	
	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string]   $helmChartVersion = '',

	[Parameter(ParameterSetName = 'Git')]
	[string]   $gitChartRepoUrl = 'https://github.com/codedx/srm-k8s',
	[Parameter(ParameterSetName = 'Git')]
	[string]   $gitChartBranchName = 'main',
	[Parameter(ParameterSetName = 'Git')]
	[string]   $gitChartPath = './chart',

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string[]] $extraValuesFiles = @(),

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[switch]   $useSealedSecrets,

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string]   $sealedSecretsNamespace = 'flux-system',

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string]   $sealedSecretsControllerName = 'sealed-secrets-controller',

	[Parameter(ParameterSetName = 'Helm')]
	[Parameter(ParameterSetName = 'Git')]
	[string]   $sealedSecretsPublicKeyPath
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

# ensure pwsh environment meets requirements
. $PSScriptRoot/../../.pwsh-check.ps1
if (-not $?) {
	Exit $LASTEXITCODE
}

$global:PSNativeCommandArgumentPassing='Legacy'

'../../.install-guided-setup-module.ps1',
'../../ps/external/powershell-algorithms/data-structures.ps1',
'../../ps/build/yaml.ps1',
'../../ps/keyvalue.ps1',
'../../ps/config.ps1' | ForEach-Object {
	$path = join-path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire GitHub repository and rerun the downloaded copy of this script."
	}
	. $path
}

function New-ResourceDirectory([string] $parentPath, [string] $name, [switch] $removeExisting) {

	$dir = Join-Path $parentPath $name
	if ((Test-Path $dir -Type Container) -and $removeExisting) {
		Remove-Item $dir -Recurse -Force | Out-Null
	}

	if (-not (Test-Path $dir -Type Container)) {
		New-Item -Path $dir -Type Directory | Out-Null
	}
	$dir
}

function Get-LatestSoftwareRiskManagerChartVersion([string] $chartRepo) {

	$tempFile = New-TemporaryFile

	# this assumes that chartRepo has the index.yaml available at https://codedx.github.io/srm-k8s/index.yaml
	Invoke-RestMethod "$chartRepo/index.yaml" | Out-File $tempFile.FullName

	$yaml = Get-Yaml $tempFile.FullName
	
	$entriesNode = $yaml.nodeGraph.vertices[$yaml.rootNodeKey].FindNeighborByKey('entries')
	$srmNode = $entriesNode.findNeighborbykey("srm")
	$entriesNode.getNeighbors() | 
		Where-Object { $_.line -gt $srmNode.line } | 
		Select-Object -First 1 | 
		ForEach-Object { $_.FindNeighborByKey('version').keyvalue }
}

if ($useSealedSecrets) {
	Write-Verbose 'Searching for kubeseal program...'
    if ($null -eq (Get-AppCommandPath 'kubeseal')) {
		Write-ErrorMessageAndExit 'Expected to find kubeseal application - is it in your PATH?'
	}
}

if ([string]::IsNullOrWhiteSpace($helmChartVersion)) {

	Write-Verbose 'Helm chart version is unspecified, fetching latest chart version...'
	$helmChartVersion = Get-LatestSoftwareRiskManagerChartVersion $helmChartRepoUrl

	Write-Verbose "Using chart version $helmChartVersion..."
}

$workDirChartResources = Join-Path $workDir 'chart-resources'
$workDirChartValuesCombined = Join-Path $workDir 'chart-values-combined'

$configJsonPath = Join-Path $workDir 'config.json'

if (-not (Test-Path $configJsonPath -PathType Leaf)) {
	Write-ErrorMessageAndExit "Unable to continue because a config.json file was not found in $workDir."
}

$config = [Config]::FromJsonFile($configJsonPath)

if ($namespace -eq "") {
	$namespace = $config.namespace
}

if ($releaseName -eq "") {
	$releaseName = $config.releaseName
}

if (-not (Test-Path $workDirChartValuesCombined -PathType Container)) {
	Write-ErrorMessageAndExit "Unable to continue because an expected directory ($workDirChartValuesCombined) was not found. Did you invoke your run-helm-prep.ps1 script?"
}

# Flux v2 artifacts will be stored in the 'flux-v2' subdirectory
Write-Verbose "Creating flux-v2 directory at $workDir..."
$fluxDir = New-ResourceDirectory $workDir 'flux-v2' -removeExisting

# Optionally create files for CRD resources
if (-not $config.skipToolOrchestration) {

	$crd = New-ResourceDirectory $fluxDir 'CRD'

	Get-ChildItem -File $PSScriptRoot/../../crds/v1 | ForEach-Object {
		Write-Verbose "Copying $_..."
		Copy-Item $_ $crd
	}
}

# Organize resources into kind directories
Write-Verbose "Organizing K8s resources..."
Get-ChildItem $workDirChartResources -Filter '*.yaml' | ForEach-Object {

	$yaml = Get-Yaml $_

	$kindKey = $yaml.nodeGraph.vertices | ForEach-Object { $_.keys } | Where-Object { $yaml.nodeGraph.vertices[$_].key -eq 'kind' } | ForEach-Object { $_ }
	if ($null -eq $kindKey) {
		Write-ErrorMessageAndExit "Unable to find kind property for resource in file $_"
	}
	$kindValue = $yaml.nodeGraph.vertices[$kindKey].keyValue

	$kindDir = New-ResourceDirectory $fluxDir $kindValue
	Copy-Item -LiteralPath $_ -Destination $kindDir
}

$secretsDirectory = Join-Path $fluxDir 'Secret'
$hasSecretResources = Test-Path $secretsDirectory -PathType Container

# Optionally use Bitnami's Sealed Secrets, replacing related resources
if ($hasSecretResources -and $useSealedSecrets) {
	
	Get-ChildItem $secretsDirectory -Filter '*.yaml' | ForEach-Object {

		Write-Verbose "Running kubeseal on $_..."
		$sealedSecretsDir = New-ResourceDirectory $fluxDir 'SealedSecret'
		$sealedSecretsPath = Join-Path $sealedSecretsDir (Split-Path $_ -Leaf)
		kubeseal --controller-name=$sealedSecretsControllerName --controller-namespace=$sealedSecretsNamespace --secret-file $_ --format yaml --cert $sealedSecretsPublicKeyPath > $sealedSecretsPath
		if ($LASTEXITCODE -ne 0) {
			Write-ErrorMessageAndExit "Unexpected exit code ($LASTEXITCODE) from kubeseal while processing '$_'"
		}

		Write-Verbose "Removing $_..."
		Remove-Item $_ -Force # Replace $_ with SealedSecret resource
	}

	$remainingSecrets = Get-ChildItem $secretsDirectory -Filter '*.yaml'
	if ($remainingSecrets.Length -eq 0) {
		Write-Verbose "Finished creating resources for SealedSecrets - removing empty directory ($secretsDirectory)..."
		Remove-Item $secretsDirectory
	}
}
$valuesFiles = @()

# Optionally include tool orchestration configuration
if (-not $config.skipToolOrchestration) {
	$valuesFiles += [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../chart/values/values-to.yaml'))
}

# Optionally TLS configuration (a $config.notes msg will request doing the prework in the comments of values-tls.yaml)
if (-not $config.skipTls) {
	$valuesFiles += [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../chart/values/values-tls.yaml'))
}

$valuesFiles += (Join-Path $workDirChartValuesCombined 'values-combined.yaml')

if ($extraValuesFiles.Length -eq 0) {

	# Automatically add an srm-extra-props.yaml found in the work directory
	$optionalSrmExtraProps = Join-Path $workDir 'srm-extra-props.yaml'
	if (Test-Path $optionalSrmExtraProps -PathType Leaf) {
		Write-Verbose "Automatically adding $optionalSrmExtraProps..."
		$valuesFiles += $optionalSrmExtraProps
	}
} else {
	$valuesFiles += $extraValuesFiles
}

$configMapDir = New-ResourceDirectory $fluxDir 'ConfigMap'

$valuesConfigMapReferences = @()
$valuesFileCount = 0
$valuesFiles | ForEach-Object {

	Write-Verbose "Processing values file $_..."
	$valuesId = $valuesFileCount++
	@"
kind: ConfigMap
apiVersion: v1
metadata:
  name: helmrelease-values-$valuesId
  namespace: $namespace
data:
  values.yaml: |
    $([string]::join("`n    ", (Get-Content $_)))
"@ | Out-File (Join-Path $configMapDir "helmrelease-values-$valuesId.yaml") -NoNewline

	$valuesConfigMapReferences += '- kind: ConfigMap'
	$valuesConfigMapReferences += "  name: helmrelease-values-$valuesId"
}

switch ($PSCmdlet.ParameterSetName) {

	'Helm' {

@"
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: srm
  namespace: $namespace
spec:
  interval: 1m
  url: $helmChartRepoUrl
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'HelmRepository') 'repo.yaml') -NoNewline

@"
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: srm
  namespace: $namespace
spec:
  releaseName: $releaseName
  timeout: 30m0s
  chart:
    spec:
      chart: srm
      version: $helmChartVersion
      sourceRef:
        kind: HelmRepository
        name: srm
        namespace: $namespace
  valuesFrom:
    $([string]::join("`n    ",$valuesConfigMapReferences))
  interval: 1m0s
  install:
    skipCRDs: true
  upgrade:
    remediation:
      retries: -1
# values:
#   web:
#     image:
#       tag: 'web-tag'
#   mariadb:
#     image:
#       tag: 'db-tag'
#   to:
#     image:
#       tag: 'tool-orchestration-tag'
#   minio:
#     image:
#       tag: 'minio-tag'
#   argo-workflows:
#     images:
#       tag: 'workflow-tag'
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'HelmRelease') 'release.yaml') -NoNewline

		break
	}

	'Git' {

@"
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: srm
  namespace: $namespace
spec:
  interval: 1m
  url: $gitChartRepoUrl
  ref:
    branch: $gitChartBranchName
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'GitRepository') 'repo.yaml') -NoNewline

@"
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: srm
  namespace: $namespace
spec:
  releaseName: $releaseName
  timeout: 30m0s
  chart:
    spec:
      chart: $gitChartPath
      version: $helmChartVersion
      sourceRef:
        kind: GitRepository
        name: srm
        namespace: $namespace
  valuesFrom:
    $([string]::join("`n    ",$valuesConfigMapReferences))
  interval: 1m0s
  install:
    skipCRDs: true
  upgrade:
    remediation:
      retries: -1
# values:
#   web:
#     image:
#       tag: 'web-tag'
#   mariadb:
#     image:
#       tag: 'db-tag'
#   to:
#     image:
#       tag: 'tool-orchestration-tag'
#   minio:
#     image:
#       tag: 'minio-tag'
#   argo-workflows:
#     images:
#       tag: 'workflow-tag'
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'HelmRelease') 'release.yaml') -NoNewline

		break
	}

}


@"
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
"@ | Out-File (Join-Path (New-ResourceDirectory $fluxDir 'Namespace') 'namespace.yaml') -NoNewline

Write-Verbose "Finished creating GitOps resources in directory $fluxDir"