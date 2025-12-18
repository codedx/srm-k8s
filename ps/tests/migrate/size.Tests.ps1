$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
	. (Join-Path $PSScriptRoot '../../keyvalue.ps1')
	. (Join-Path $PSScriptRoot '../../config.ps1')
	. (Join-Path $PSScriptRoot '../../../admin/migrate/.ps/.common.ps1')
}

Describe 'Migration config' -Tag 'upgrade' {

	It 'should switch to Unspecified system size' {

		Mock Get-DirectoryPath {
			$TestDrive
		} -ParameterFilter { $prompt -eq "Enter a new SRM work directory that differs from the old one" }
	
		Mock Get-QuestionResponse {
			'srm'
		} -ParameterFilter { $prompt -eq "Enter your SRM namespace (do not reuse your Code Dx namespace)" }
	
		Mock Get-QuestionResponse {
			'srm'
		} -ParameterFilter { $prompt -eq "Enter your SRM release (do not reuse your Code Dx release name)" }
	
		Mock Get-FilePath {
			Join-Path $TestDrive 'license.lic'
		} -ParameterFilter { $prompt -eq "Enter the path to your SRM license file" }
	
		Mock Get-QuestionResponse {
			'srm.local'
		} -ParameterFilter { $prompt -eq "Enter your SRM DNS name (do not reuse your Code Dx hostname - you can switch back post-migration)" }
	
		Mock Get-MultipleChoiceQuestionResponse {
			0
		} -ParameterFilter { $prompt -eq "Select a System Size (recommended) or choose Unspecified to keep individual resource reservations (e.g., CPU, memory, etc.)"}
	
		Mock Read-HostSecureText {
			'password'
		} -ParameterFilter { $prompt -eq "`nSpecify a password to protect your config.json file" }

		Mock Get-CodeDxHelmChartVersionString {
			'20xx.xx.xx'
		}

		Mock Get-SrmHelmChartVersionString {
			'20xx.xx.xx'
		}

		$workingDirectory = Join-Path $TestDrive ([Guid]::NewGuid())

		$coreDirectory = New-Item -ItemType Container -Force (Join-Path $workingDirectory 'git/codedx-kubernetes/setup/core')
		$chartsDirectory = New-Item -ItemType Container -Force (Join-Path $workingDirectory 'git/codedx-kubernetes/setup/core/charts/codedx')

		$setupScriptPath = Join-Path $coreDirectory 'setup.ps1'
		Out-File -LiteralPath $setupScriptPath -InputObject ''

		$chartPath = Join-Path $chartsDirectory 'Chart.yaml'
		Out-File -LiteralPath $chartPath -InputObject 'appVersion: "2024.9.0"'
		
		$migrateParams = @{
			'-codeDxSetupScriptPath' = $setupScriptPath
			'-workDir' = $workingDirectory
			'-kubeContextName' = 'kind-kind'
			'-kubeApiTargetPort' = 6443
			'-namespaceCodeDx' = 'cdx-app'
			'-releaseNameCodeDx' = 'codedx'
			'-codeDxMemoryReservation' = '8192Mi'
			'-dbMasterMemoryReservation' = '8192Mi'
			'-dbSlaveMemoryReservation' = '8192Mi'
			'-toolServiceMemoryReservation' = '500Mi'
			'-minioMemoryReservation' = '5120Mi'
			'-workflowMemoryReservation' = '500Mi'
			'-codeDxCPUReservation' = '2000m'
			'-dbMasterCPUReservation' = '2000m'
			'-dbSlaveCPUReservation' = '1000m'
			'-minioCPUReservation' = '2000m'
			'-codeDxEphemeralStorageReservation' = '3368Mi'
			'-serviceTypeCodeDx' = 'ClusterIP'
			'-codedxAdminPwd' = 'password'
			'-codedxDatabaseUserPwd' = 'password'
			'-skipTls' = $true
			'-skipServiceTls' = $true
			'-skipPSPs' = $true
			'-skipNetworkPolicies' = $true
			'-skipIngressEnabled' = $true
			'-skipUseRootDatabaseUser' = $true
			'-codeDxVolumeSizeGiB' = 64
			'-codeDxTlsServicePortNumber' = 9443
			'-dbVolumeSizeGiB' = 64
			'-dbSlaveVolumeSizeGiB' = 64
			'-dbSlaveReplicaCount' = 1
			'-mariadbRootPwd' = 'password'
			'-mariadbReplicatorPwd' = 'password'
			'-minioVolumeSizeGiB' = 64
			'-toolServiceReplicas' = 1
			'-namespaceToolOrchestration' = 'cdx-svc'
			'-releaseNameToolOrchestration' = 'codedx-tool-orchestration'
			'-toolServiceApiKey' = 'password'
			'-minioAdminPwd' = 'password'
		}
		& (Join-Path $PSScriptRoot '../../../admin/migrate/.ps/.migrate.ps1') @migrateParams


		$config = [Config]::FromJsonFile((Join-Path $TestDrive 'config.json'))

		$config.systemSize -eq 'Unspecified' | Should -BeTrue

		$config.useCPUDefaults | Should -BeFalse
		$config.webCPUReservation | Should -Be '2000m'
		$config.dbMasterCPUReservation | Should -Be '2000m'
		$config.dbSlaveCPUReservation | Should -Be '1000m'
		$config.toolServiceCPUReservation | Should -Be '1000m'
		$config.minioCPUReservation | Should -Be '2000m'
		$config.workflowCPUReservation | Should -Be '500m'

		$config.useMemoryDefaults | Should -BeFalse
		$config.webMemoryReservation | Should -Be '8192Mi'
		$config.dbMasterMemoryReservation | Should -Be '8192Mi'
		$config.dbSlaveMemoryReservation | Should -Be '8192Mi'
		$config.toolServiceMemoryReservation | Should -Be '500Mi'
		$config.minioMemoryReservation | Should -Be '5120Mi'
		$config.workflowMemoryReservation | Should -Be '500Mi'

		$config.useVolumeSizeDefaults | Should -BeFalse
		$config.webVolumeSizeGiB | Should -BeExactly 64
		$config.dbVolumeSizeGiB | Should -BeExactly 64
		$config.dbSlaveVolumeSizeGiB | Should -BeExactly 64
		$config.dbSlaveBackupVolumeSizeGiB | Should -BeExactly 64
		$config.minioVolumeSizeGiB | Should -BeExactly 64
	}

	It 'should switch to Medium system size' {

		Mock Get-DirectoryPath {
			$TestDrive
		} -ParameterFilter { $prompt -eq "Enter a new SRM work directory that differs from the old one" }
	
		Mock Get-QuestionResponse {
			'srm'
		} -ParameterFilter { $prompt -eq "Enter your SRM namespace (do not reuse your Code Dx namespace)" }
	
		Mock Get-QuestionResponse {
			'srm'
		} -ParameterFilter { $prompt -eq "Enter your SRM release (do not reuse your Code Dx release name)" }
	
		Mock Get-FilePath {
			Join-Path $TestDrive 'license.lic'
		} -ParameterFilter { $prompt -eq "Enter the path to your SRM license file" }
	
		Mock Get-QuestionResponse {
			'srm.local'
		} -ParameterFilter { $prompt -eq "Enter your SRM DNS name (do not reuse your Code Dx hostname - you can switch back post-migration)" }
	
		Mock Get-MultipleChoiceQuestionResponse {
			2
		} -ParameterFilter { $prompt -eq "Select a System Size (recommended) or choose Unspecified to keep individual resource reservations (e.g., CPU, memory, etc.)"}
	
		Mock Read-HostSecureText {
			'password'
		} -ParameterFilter { $prompt -eq "`nSpecify a password to protect your config.json file" }

		Mock Get-CodeDxHelmChartVersionString {
			'20xx.xx.xx'
		}

		Mock Get-SrmHelmChartVersionString {
			'20xx.xx.xx'
		}

		$workingDirectory = Join-Path $TestDrive ([Guid]::NewGuid())

		$coreDirectory = New-Item -ItemType Container -Force (Join-Path $workingDirectory 'git/codedx-kubernetes/setup/core')
		$chartsDirectory = New-Item -ItemType Container -Force (Join-Path $workingDirectory 'git/codedx-kubernetes/setup/core/charts/codedx')

		$setupScriptPath = Join-Path $coreDirectory 'setup.ps1'
		Out-File -LiteralPath $setupScriptPath -InputObject ''

		$chartPath = Join-Path $chartsDirectory 'Chart.yaml'
		Out-File -LiteralPath $chartPath -InputObject 'appVersion: "2024.9.0"'
		
		$migrateParams = @{
			'-codeDxSetupScriptPath' = $setupScriptPath
			'-workDir' = $workingDirectory
			'-kubeContextName' = 'kind-kind'
			'-kubeApiTargetPort' = 6443
			'-namespaceCodeDx' = 'cdx-app'
			'-releaseNameCodeDx' = 'codedx'
			'-codeDxMemoryReservation' = '8192Mi'
			'-dbMasterMemoryReservation' = '8192Mi'
			'-dbSlaveMemoryReservation' = '8192Mi'
			'-toolServiceMemoryReservation' = '500Mi'
			'-minioMemoryReservation' = '5120Mi'
			'-workflowMemoryReservation' = '500Mi'
			'-codeDxCPUReservation' = '2000m'
			'-dbMasterCPUReservation' = '2000m'
			'-dbSlaveCPUReservation' = '1000m'
			'-minioCPUReservation' = '2000m'
			'-codeDxEphemeralStorageReservation' = '3368Mi'
			'-serviceTypeCodeDx' = 'ClusterIP'
			'-codedxAdminPwd' = 'password'
			'-codedxDatabaseUserPwd' = 'password'
			'-skipTls' = $true
			'-skipServiceTls' = $true
			'-skipPSPs' = $true
			'-skipNetworkPolicies' = $true
			'-skipIngressEnabled' = $true
			'-skipUseRootDatabaseUser' = $true
			'-codeDxVolumeSizeGiB' = 64
			'-codeDxTlsServicePortNumber' = 9443
			'-dbVolumeSizeGiB' = 64
			'-dbSlaveVolumeSizeGiB' = 64
			'-dbSlaveReplicaCount' = 1
			'-mariadbRootPwd' = 'password'
			'-mariadbReplicatorPwd' = 'password'
			'-minioVolumeSizeGiB' = 64
			'-toolServiceReplicas' = 1
			'-namespaceToolOrchestration' = 'cdx-svc'
			'-releaseNameToolOrchestration' = 'codedx-tool-orchestration'
			'-toolServiceApiKey' = 'password'
			'-minioAdminPwd' = 'password'
		}
		& (Join-Path $PSScriptRoot '../../../admin/migrate/.ps/.migrate.ps1') @migrateParams


		$config = [Config]::FromJsonFile((Join-Path $TestDrive 'config.json'))

		$config.systemSize -eq 'Medium' | Should -BeTrue

		$config.useCPUDefaults | Should -BeFalse
		$config.webCPUReservation | Should -BeNullOrEmpty
		$config.dbMasterCPUReservation | Should -BeNullOrEmpty
		$config.dbSlaveCPUReservation | Should -BeNullOrEmpty
		$config.toolServiceCPUReservation | Should -BeNullOrEmpty
		$config.minioCPUReservation | Should -BeNullOrEmpty
		$config.workflowCPUReservation | Should -BeNullOrEmpty

		$config.useMemoryDefaults | Should -BeFalse
		$config.webMemoryReservation | Should -BeNullOrEmpty
		$config.dbMasterMemoryReservation | Should -BeNullOrEmpty
		$config.dbSlaveMemoryReservation | Should -BeNullOrEmpty
		$config.toolServiceMemoryReservation | Should -BeNullOrEmpty
		$config.minioMemoryReservation | Should -BeNullOrEmpty
		$config.workflowMemoryReservation | Should -BeNullOrEmpty

		$config.useVolumeSizeDefaults | Should -BeFalse
		$config.webVolumeSizeGiB | Should -BeExactly 0
		$config.dbVolumeSizeGiB | Should -BeExactly 0
		$config.dbSlaveVolumeSizeGiB | Should -BeExactly 0
		$config.dbSlaveBackupVolumeSizeGiB | Should -BeExactly 0
		$config.minioVolumeSizeGiB | Should -BeExactly 0
	}
}