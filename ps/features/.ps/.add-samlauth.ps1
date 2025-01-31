<#PSScriptInfo
.VERSION 1.2.0
.GUID 6d09e56c-f2a0-4f56-828e-0a676d08fe6a
.AUTHOR Black Duck
.COPYRIGHT Copyright 2024 Black Duck Software, Inc. All rights reserved.
#>

using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }
param (
	[Parameter(Mandatory=$true)][string] $configPath,
	[string] $configFilePwd
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Set-PSDebug -Strict

Write-Host 'Loading...' -NoNewline

'../../keyvalue.ps1',
'../../build/protect.ps1',
'../../config.ps1',
'../../steps/step.ps1',
'../../steps/auth.ps1',
'../../steps/finish.ps1' | ForEach-Object {
	Write-Debug "'$PSCommandPath' is including file '$_'"
	$path = Join-Path $PSScriptRoot $_
	if (-not (Test-Path $path)) {
		Write-Error "Unable to find file script dependency at $path. Please download the entire srm-k8s GitHub repository and rerun the downloaded copy of this script."
	}
	. $path | out-null
}

$config = [Config]::FromJsonFile($configPath)

$workDirectory = $config.workDir
$configDirectory = Split-Path (Resolve-Path $configPath)

# use GetFullPath to normalize directory separators (e.g., convert C:\Users\user/.k8s-srm to C:\Users\user\.k8s-srm)
$workDirectoryFullName   = [IO.Path]::GetFullPath($workDirectory)
$configDirectoryFullName = [IO.Path]::GetFullPath($configDirectory)
$isConfigInWorkDirectory = $workDirectoryFullName -eq $configDirectoryFullName

if (-not $isConfigInWorkDirectory) {
	# wizard writes the updated config.json to the work directory
	Write-Error "Unable to continue because your config.json file must reside in your work directory. Move your config.json file from '$configDirectoryFullName' to '$workDirectoryFullName' before retrying."
}

if ($config.isLocked) {

	if ([string]::IsNullOrEmpty($configFilePwd)) {
		$configFilePwd = Read-HostSecureText -Prompt 'Enter config file password'
	}

	$config.Unlock($configFilePwd)
}

# make a backup copy of the config file
Copy-Item $configPath ([IO.Path]::ChangeExtension($configPath, '.json.bak')) -Force

$graph = New-Object Graph($true)

$s = @{}
[AbortAddSaml],
[Finish],
[Lock],
[SamlAppName],
[SamlAuthenticationHostBasePath],
[SamlExtraConfig],
[SamlIdpMetadata],
[SamlKeystorePwd],
[SamlPrivateKeyPwd],
[UseSaml],
[WelcomeAddSaml] | ForEach-Object {
	Write-Debug "Creating $_ object..."
	$s[$_] = new-object -type $_ -args $config
	Add-Step $graph $s[$_]
}

Add-StepTransitions $graph $s[[WelcomeAddSaml]] $s[[UseSaml]],$s[[AbortAddSaml]]
Add-StepTransitions $graph $s[[WelcomeAddSaml]] $s[[UseSaml]], `
	$s[[SamlAuthenticationHostBasePath]],$s[[SamlIdpMetadata]],$s[[SamlAppName]],$s[[SamlKeystorePwd]],$s[[SamlPrivateKeyPwd]],$s[[SamlExtraConfig]],
	$s[[Lock]],$s[[Finish]]

if ($DebugPreference -eq 'Continue') {
	# Print graph at https://dreampuf.github.io/GraphvizOnline (select 'dot' Engine and use Format 'png-image-element')
	write-host 'digraph G {'
	$s.keys | ForEach-Object { $node = $s[$_]; ($node.getNeighbors() | ForEach-Object { write-host ('{0} -> {1};' -f $node.name,$_) }) }
	write-host '}'
}

try {
	$vStack = Invoke-GuidedSetup 'SRM - Add SAML Authentication Wizard' $s[[WelcomeAddSaml]] ($s[[Finish]],$s[[AbortAddSaml]])

	Write-StepGraph (Join-Path ($config.workDir ?? './') 'graph.wiz.saml.path') $s $vStack
} catch {
	Write-Host "`n`nAn unexpected error occurred: $_`n"
	Write-Host $_.ScriptStackTrace
}