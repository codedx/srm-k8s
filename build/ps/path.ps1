function Get-ChartPath([string] $repoDir) {
	Join-Path $repoDir 'chart'
}

function Get-DatabaseValuesPath([string] $repoDir) {
	Join-Path (Get-ChartPath($repoDir)) 'values.yaml'
}

function Get-DeploymentGuidePath([string] $repoDir) {
	Join-Path $repoDir 'docs/DeploymentGuide.md'
}

function Get-RegistryDocPath([string] $repoDir) {
	Join-Path $repoDir 'docs/deploy/registry.md'
}

function Get-RegistryScriptPath([string] $repoDir) {
	Join-Path $repoDir 'docs/deploy/registry.ps1'
}


function Get-RestoreDatabaseScriptPath([string] $repoDir) {
	Join-Path $repoDir 'admin/db/restore-db.ps1'
}

function Get-ToolOrchestrationValuesPath([string] $repoDir) {
	Join-Path (Get-ChartPath($repoDir)) 'values/values-to.yaml'
}

function Get-WebValuesPath([string] $repoDir) {
	Join-Path (Get-ChartPath($repoDir)) 'values.yaml'
}