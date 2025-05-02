using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
	. (Join-Path $PSScriptRoot '../wizard-common/mock.ps1')
	. (Join-Path $PSScriptRoot '../../keyvalue.ps1')
	. (Join-Path $PSScriptRoot '../../build/protect.ps1')
	. (Join-Path $PSScriptRoot '../../config.ps1')
}

Describe 'Specifying TO and custom Docker images' -Tag 'size' {

	It 'Should include MinIO Docker image when using MinIO' {

        $global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		0, # Unspecified (Deployment Size)
		'srm-web-license', # License
		$TestDrive, # Work Directory
		4, # Other (Kubernetes Environment)
		'srm', # Namespace
		'srm-release', # Release
		1, # no (External Database)
		0, # 0 replicas (Database Replicas)
		1, # no (Scan Farm)
		1, # no (Docker Registry)
		0, # yes (Tool Orchestration)
		0, # on-cluster (Orchestrated Analysis Storage)
		0, # no (Configure TLS)
		1, # no (Network Policy)
		0, # Local Accounts (Authentication Type)
		2, # ClusterIP (Ingress Type)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		0, # yes (Docker Images)
        'web', # (SRM Web Docker Image)
        'db', # (SRM MariaDB Docker Image)
        'to', # (SRM Tool Orchestration Docker Image)
        'minio', # (MinIO Docker Image)
        'workflow', # (SRM Workflow Docker Image)
		0, # defaults (CPU Reservations)
		0, # defaults (Memory Reservations)
		0, # defaults (Storage Reservations)
		0, # defaults (Volume Sizes)
		$null, # Storage Provider
		1, # no (Auth Cookie Secure)
		1, # no (Node Selectors)
		1, # no (Pod Tolerations)
		0 # save (Finish)
		| ForEach-Object {
			$global:inputs.enqueue($_)
		}

        New-Mocks
		Mock -ModuleName Guided-Setup Test-Path {
			$true
	   	} -ParameterFilter { 'srm-web-license' -contains [IO.Path]::GetFileName($path) }

		. (Join-Path $PSScriptRoot ../../../helm-prep-wizard.ps1)

		$configFile = Join-Path $TestDrive 'config.json'

		$config = [Config]::FromJsonFile($configFile)

		$config.imageVersionMinio | Should -Be 'minio' -Because "a MinIO Docker image was entered"
    }

    It 'Should not include MinIO Docker image when not using MinIO' {

        $global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		0, # Unspecified (Deployment Size)
		'srm-web-license', # License
		$TestDrive, # Work Directory
		4, # Other (Kubernetes Environment)
		'srm', # Namespace
		'srm-release', # Release
		1, # no (External Database)
		0, # 0 replicas (Database Replicas)
		1, # no (Scan Farm)
		1, # no (Docker Registry)
		0, # yes (Tool Orchestration)
        1, # access-key (Orchestrated Analysis Storage)
        'endpoint', # (Orchestrated Analysis Storage Endpoint)
        0, # yes (Orchestrated Analysis Storage Endpoint Security)
        'username', # (Orchestrated Analysis Storage Username)
        (New-Password 'password'), # (Orchestrated Analysis Storage Password)
        (New-Password 'password'), # confirm (Orchestrated Analysis Storage Password)
        'bucket', # (Orchestrated Analysis Storage Bucket)
        1, # no (Orchestrated Analysis Storage Trust)
		0, # no (Configure TLS)
		1, # no (Network Policy)
		0, # Local Accounts (Authentication Type)
		2, # ClusterIP (Ingress Type)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		0, # yes (Docker Images)
        'web', # (SRM Web Docker Image)
        'db', # (SRM MariaDB Docker Image)
        'to', # (SRM Tool Orchestration Docker Image)
        'workflow', # (SRM Workflow Docker Image)
		0, # defaults (CPU Reservations)
		0, # defaults (Memory Reservations)
		0, # defaults (Storage Reservations)
		0, # defaults (Volume Sizes)
		$null, # Storage Provider
		1, # no (Auth Cookie Secure)
		1, # no (Node Selectors)
		1, # no (Pod Tolerations)
        (New-Password 'password'), # (Lock Config JSON)
        (New-Password 'password'), # confirm (Lock Config JSON)
		0 # save (Finish)
		| ForEach-Object {
			$global:inputs.enqueue($_)
		}

        New-Mocks
		Mock -ModuleName Guided-Setup Test-Path {
			$true
	   	} -ParameterFilter { 'srm-web-license' -contains [IO.Path]::GetFileName($path) }

		. (Join-Path $PSScriptRoot ../../../helm-prep-wizard.ps1)

		$configFile = Join-Path $TestDrive 'config.json'

		$config = [Config]::FromJsonFile($configFile)

		$config.imageVersionMinio | Should -Be '' -Because "a MinIO Docker image was not entered"
    }
}