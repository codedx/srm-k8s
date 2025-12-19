$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
	. (Join-Path $PSScriptRoot '../../keyvalue.ps1')
	. (Join-Path $PSScriptRoot '../../build/protect.ps1')
	. (Join-Path $PSScriptRoot '../../config.ps1')
}

Describe 'ConvertStorageToMi' -Tag 'ephemeral-storage' {

	It 'should convert Mi notation' {
		[Config]::ConvertStorageToMi('2868Mi') | Should -Be 2868
		[Config]::ConvertStorageToMi('3368Mi') | Should -Be 3368
	}

	It 'should convert MiB notation' {
		[Config]::ConvertStorageToMi('2868MiB') | Should -Be 2868
		[Config]::ConvertStorageToMi('3368MiB') | Should -Be 3368
	}

	It 'should convert Gi notation' {
		[Config]::ConvertStorageToMi('3Gi') | Should -Be 3072
		[Config]::ConvertStorageToMi('4Gi') | Should -Be 4096
	}

	It 'should convert GiB notation' {
		[Config]::ConvertStorageToMi('3GiB') | Should -Be 3072
		[Config]::ConvertStorageToMi('4GiB') | Should -Be 4096
	}

	It 'should convert Ki notation' {
		[Config]::ConvertStorageToMi('1024Ki') | Should -Be 1
		[Config]::ConvertStorageToMi('2048Ki') | Should -Be 2
	}

	It 'should convert KiB notation' {
		[Config]::ConvertStorageToMi('1024KiB') | Should -Be 1
		[Config]::ConvertStorageToMi('2048KiB') | Should -Be 2
	}

	It 'should convert Ti notation' {
		[Config]::ConvertStorageToMi('1Ti') | Should -Be 1048576
	}

	It 'should convert raw bytes' {
		[Config]::ConvertStorageToMi('1048576') | Should -Be 1
		[Config]::ConvertStorageToMi('3534848000') | Should -Be 3371
	}

	It 'should handle small byte values by truncating' {
		[Config]::ConvertStorageToMi('10') | Should -Be 0
		[Config]::ConvertStorageToMi('100') | Should -Be 0
		[Config]::ConvertStorageToMi('1000') | Should -Be 0
	}

	It 'should return 0 for empty string' {
		[Config]::ConvertStorageToMi('') | Should -Be 0
	}

	It 'should return 0 for null' {
		[Config]::ConvertStorageToMi($null) | Should -Be 0
	}

	It 'should handle decimal values' {
		[Config]::ConvertStorageToMi('2.5Gi') | Should -Be 2560
		[Config]::ConvertStorageToMi('1.5Mi') | Should -Be 2
	}
}

Describe 'Web Ephemeral Storage Minimum Validation' -Tag 'ephemeral-storage' {

	It 'should upgrade 2868Mi to 3368Mi' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "2868Mi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$config.webEphemeralStorageReservation | Should -Be '3368Mi'
	}

	It 'should upgrade 3Gi to 3368Mi' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "3Gi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$config.webEphemeralStorageReservation | Should -Be '3368Mi'
	}

	It 'should preserve 4Gi when already above minimum' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "4Gi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$config.webEphemeralStorageReservation | Should -Be '4Gi'
	}

	It 'should preserve 5000Mi when already above minimum' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "5000Mi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$config.webEphemeralStorageReservation | Should -Be '5000Mi'
	}

	It 'should add note when upgrading from 2868Mi' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "2868Mi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$note = $config.notes | Where-Object { $_.key -eq 'webEphemeralStorageReservation' }
		$note | Should -Not -BeNullOrEmpty
		$note.value | Should -Be '- Automatically increased webEphemeralStorageReservation from 2868Mi to 3368Mi to meet minimum requirements'
	}

	It 'should add note when upgrading from 3Gi' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "3Gi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$note = $config.notes | Where-Object { $_.key -eq 'webEphemeralStorageReservation' }
		$note | Should -Not -BeNullOrEmpty
		$note.value | Should -Be '- Automatically increased webEphemeralStorageReservation from 3Gi to 3368Mi to meet minimum requirements'
	}

	It 'should not add note when value is already sufficient' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "4Gi",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$note = $config.notes | Where-Object { $_.key -eq 'webEphemeralStorageReservation' }
		$note | Should -BeNullOrEmpty
	}

	It 'should upgrade raw byte value below minimum' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "10",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		$config.webEphemeralStorageReservation | Should -Be '3368Mi'
	}

	It 'should handle missing webEphemeralStorageReservation' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		# Should not throw an error
		$config | Should -Not -BeNullOrEmpty
	}

	It 'should handle empty webEphemeralStorageReservation' {
		$configJsonPath = Join-Path $TestDrive ([Guid]::NewGuid())
		@'
		{
			"configVersion": "1.10",
			"namespace": "srm",
			"releaseName": "srm",
			"workDir": "/tmp",
			"webEphemeralStorageReservation": "",
			"notes": []
		}
'@ | Out-File $configJsonPath

		$config = [Config]::FromJsonFile($configJsonPath)
		# Should not throw an error and should remain empty
		$config.webEphemeralStorageReservation | Should -Be ''
	}
}
