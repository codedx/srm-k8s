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

Describe 'Specifying no system size' -Tag 'size' {

	It 'Core feature should include reservations' {

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
		1, # no (Tool Orchestration)
		0, # no (Configure TLS)
		1, # no (Network Policy)
		0, # Local Accounts (Authentication Type)
		2, # ClusterIP (Ingress Type)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
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

		$config.systemSize | Should -Be 'Unspecified' -Because "a system size was not entered"

		$config.webCPUReservation | Should -Be '4000m' -Because "a web CPU reservation was specified"
		$config.dbMasterCPUReservation | Should -Be '4000m' -Because "a DB CPU reservation was specified"
		$config.toolServiceCPUReservation | Should -Be '' -Because "Tool Orchestration was not included"
		$config.minioCPUReservation | Should -Be '' -Because "Tool Orchestration was not included"
		$config.workflowCPUReservation | Should -Be '' -Because "Tool Orchestration was not included"

		$config.webMemoryReservation | Should -Be '16384Mi' -Because "a web memory reservation was specified"
		$config.dbMasterMemoryReservation | Should -Be '16384Mi' -Because "a DB memory reservation was specified"
		$config.toolServiceMemoryReservation | Should -Be '' -Because "Tool Orchestration was not included"
		$config.minioMemoryReservation | Should -Be '' -Because "Tool Orchestration was not included"
		$config.workflowMemoryReservation | Should -Be '' -Because "Tool Orchestration was not included"

		$config.webEphemeralStorageReservation | Should -Be '2868Mi' -Because "a web storage reservation was specified"

		$config.webVolumeSizeGiB | Should -Be '64' -Because "a web volume size was specified"
		$config.dbVolumeSizeGiB | Should -Be '64' -Because "a DB volume size reservation was specified"
	}

	It 'Tool Orchestration feature should include reservations' {

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
		1, # no (Docker Images)
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

		$config.systemSize | Should -Be 'Unspecified' -Because "a system size was not entered"

		$config.webCPUReservation | Should -Be '4000m' -Because "a web CPU reservation was specified"
		$config.dbMasterCPUReservation | Should -Be '4000m' -Because "a DB CPU reservation was specified"
		$config.toolServiceCPUReservation | Should -Be '1000m' -Because "a Tool Service CPU reservation was specified"
		$config.minioCPUReservation | Should -Be '2000m' -Because "a MinIO CPU reservation was specified"
		$config.workflowCPUReservation | Should -Be '500m' -Because "a workflow CPU reservation was specified"

		$config.webMemoryReservation | Should -Be '16384Mi' -Because "a web memory reservation was specified"
		$config.dbMasterMemoryReservation | Should -Be '16384Mi' -Because "a DB memory reservation was specified"
		$config.toolServiceMemoryReservation | Should -Be '1024Mi' -Because "a Tool Service memory reservation was specified"
		$config.minioMemoryReservation | Should -Be '5120Mi' -Because "a MinIO memory reservation was specified"
		$config.workflowMemoryReservation | Should -Be '500Mi' -Because "a workflow memory reservation was specified"

		$config.webEphemeralStorageReservation | Should -Be '2868Mi' -Because "a web storage reservation was specified"

		$config.webVolumeSizeGiB | Should -Be '64' -Because "a web volume size was specified"
		$config.dbVolumeSizeGiB | Should -Be '64' -Because "a DB volume size reservation was specified"
		$config.minioVolumeSizeGiB | Should -Be '64' -Because "a MinIO volume size reservation was specified"
	}
}

Describe 'Specifying Medium system size' -Tag 'size' {

	It 'Core feature should not include reservations' {

		$global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		2, # Medium (Deployment Size)
		'srm-web-license', # License
		$TestDrive, # Work Directory
		4, # Other (Kubernetes Environment)
		'srm', # Namespace
		'srm-release', # Release
		1, # no (External Database)
		0, # 0 replicas (Database Replicas)
		1, # no (Scan Farm)
		1, # no (Docker Registry)
		1, # no (Tool Orchestration)
		0, # no (Configure TLS)
		1, # no (Network Policy)
		0, # Local Accounts (Authentication Type)
		2, # ClusterIP (Ingress Type)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
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
		$config.systemSize | Should -Be 'Medium' -Because "a Medium system size was expected"
		$config.webCPUReservation | Should -Be '' -Because "a system size was specified"
	}

	It 'Tool Orchestration feature should not include reservations' {

		$global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		2, # Medium (Deployment Size)
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
		1, # no (Docker Images)
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
		$config.systemSize | Should -Be 'Medium' -Because "a Medium system size was expected"
		$config.webCPUReservation | Should -Be '' -Because "a system size was specified"
		$config.webMemoryReservation | Should -Be '' -Because "a system size was specified"
		$config.dbMasterCPUReservation | Should -Be '' -Because "a system size was specified"
		$config.dbMasterMemoryReservation | Should -Be '' -Because "a system size was specified"
		$config.toolServiceReplicas | Should -Be 0 -Because "a system size was specified"
	}
}
