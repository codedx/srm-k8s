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

Describe 'Wizard should prompt for auth cookie secure' -Tag 'size' {

	It 'Secure should be true when using HTTPS' {

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
		0, # yes (Auth Cookie Secure)
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}

	It 'Secure should be false when not using HTTPS' {

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

		$config.authCookieSecure | Should -BeFalse -Because "HTTPS will not be used"
	}
}

Describe 'Wizard should not prompt for auth cookie secure' -Tag 'size' {

	It 'Secure should be set for Classic ELB ingress' {

		$global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		0, # Unspecified (Deployment Size)
		'srm-web-license', # License
		$TestDrive, # Work Directory
		2, # EKS (Kubernetes Environment)
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
		5, # ClassicElb (Ingress Type)
		'arn', # (AWS Certificate ARN)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
		$null, # Storage Provider
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}

	It 'Secure should be set for Network ELB ingress' {

		$global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		0, # Unspecified (Deployment Size)
		'srm-web-license', # License
		$TestDrive, # Work Directory
		2, # EKS (Kubernetes Environment)
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
		6, # NetworkElb (Ingress Type)
		'arn', # (AWS Certificate ARN)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
		$null, # Storage Provider
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}

	It 'Secure should be set for Internal Classic ELB ingress' {

		$global:inputs = new-object collections.queue
		$null, # welcome
		0, # yes (About)
		0, # Unspecified (Deployment Size)
		'srm-web-license', # License
		$TestDrive, # Work Directory
		2, # EKS (Kubernetes Environment)
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
		7, # InternalClassicElb (Ingress Type)
		'arn', # (AWS Certificate ARN)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
		$null, # Storage Provider
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}

	It 'Secure should be set for Cert Manager Issuer ingress' {

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
		0, # NginxIngressCommunity (Ingress Type)
		'nginx', # (Ingress Class Name)
		1, # Cert-Manager Issuer (Ingress TLS)
		'issuer', # (Cert-Manager Issuer)
		'dns', # (SRM DNS Name)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
		$null, # Storage Provider
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}

	It 'Secure should be set for Cert Manager Issuer ingress' {

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
		0, # NginxIngressCommunity (Ingress Type)
		'nginx', # (Ingress Class Name)
		2, # Cert-Manager ClusterIssuer (Ingress TLS)
		'issuer', # (Cert-Manager Issuer)
		'dns', # (SRM DNS Name)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
		$null, # Storage Provider
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}

	It 'Secure should be set for External TLS Other ingress' {

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
		1, # OtherIngress (Ingress Type)
		'ingress', # (Ingress Class Name)
		3, # External Kubernetes TLS Secret (Ingress TLS)
		'tls', # (Ingress TLS Secret Name)
		'dns', # (SRM DNS Name)
		0, # yes (Default Java cacerts)
		0, # yes (Auto-Generated Passwords)
		1, # no (Docker Images)
		0, # use recommended (CPU Reservations)
		0, # use recommended (Memory Reservations)
		0, # use recommended (Ephemeral Storage Reservations)
		0, # use recommended (Volume Sizes)
		$null, # Storage Provider
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

		$config.authCookieSecure | Should -BeTrue -Because "HTTPS will be used"
	}
}
