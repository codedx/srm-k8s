<#PSScriptInfo
.VERSION 1.3.0
.GUID 77c562f2-fba7-4c91-8499-e3a8b26e9e7e
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
'../../steps/finish.ps1',
'../../steps/java.ps1' | ForEach-Object {
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

# Adding extra certificates to trust means updating a local cacerts file
$config.useDefaultCACerts = $false

# make a backup copy of the config file
Copy-Item $configPath ([IO.Path]::ChangeExtension($configPath, '.json.bak')) -Force

$graph = New-Object Graph($true)

$s = @{}
[WelcomeAddCertificates],
[AddExtraCertificates],
[AbortAddCertificates],
[CACertsFile],
[CACertsFilePassword],
[ExtraCertificates],
[Lock],
[Finish]
 | ForEach-Object {
	Write-Debug "Creating $_ object..."
	$s[$_] = new-object -type $_ -args $config
	Add-Step $graph $s[$_]
}

Add-StepTransitions $graph $s[[WelcomeAddCertificates]] $s[[AddExtraCertificates]],$s[[AbortAddCertificates]]
Add-StepTransitions $graph $s[[WelcomeAddCertificates]] $s[[AddExtraCertificates]],$s[[CACertsFile]],$s[[CACertsFilePassword]],$s[[ExtraCertificates]],$s[[Lock]],$s[[Finish]]

if ($DebugPreference -eq 'Continue') {
	# Print graph at https://dreampuf.github.io/GraphvizOnline (select 'dot' Engine and use Format 'png-image-element')
	write-host 'digraph G {'
	$s.keys | ForEach-Object { $node = $s[$_]; ($node.getNeighbors() | ForEach-Object { write-host ('{0} -> {1};' -f $node.name,$_) }) }
	write-host '}'
}

try {
	$vStack = Invoke-GuidedSetup 'SRM - Add Certificates Wizard' $s[[WelcomeAddCertificates]] ($s[[Finish]],$s[[AbortAddCertificates]])
	Write-StepGraph (Join-Path ($config.workDir ?? './') 'graph.wiz.certs.path') $s $vStack
} catch {
	Write-Host "`n`nAn unexpected error occurred: $_`n"
	Write-Host $_.ScriptStackTrace
}