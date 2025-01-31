[ConfigAttribute(("srmLicenseFile"))]
class SrmWebLicense : Step {
	static [string] hidden $description = @'
Your Software Risk Manager license determines the features available
in your deployment.
'@

	SrmWebLicense([Config] $config) : base(
		[SrmWebLicense].Name, 
		$config,
		'SRM License',
		[SrmWebLicense]::description,
		'Enter the path to your SRM license file') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.srmLicenseFile = ([PathQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.srmLicenseFile = ''
	}
}

[ConfigAttribute(("scanFarmType","skipScanFarm"))]
class ScanFarmType : Step {
	static [string] hidden $description = @'
The Scan Farm feature includes both SAST and SCA scanning, depending on
your license type.
'@

	ScanFarmType([Config] $config) : base(
		[ScanFarmType].Name, 
		$config,
		'Scan Farm Type',
		[ScanFarmType]::description,
		'What type of Scan Farm license do you have?') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$choices = @(
			[tuple]::create('SAST', 'My Scan Farm license includes SAST scanning only')
			[tuple]::create('SCA', 'My Scan Farm license includes SCA scanning only')
			[tuple]::create('B&oth', 'My Scan Farm license includes both SAST and SCA scanning')
		)
		return new-object MultipleChoiceQuestion($prompt, $choices, 0)
	}
	
	[bool]HandleResponse([IQuestion] $question) {

		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.scanFarmType = [ScanFarmLicenseType]::Sast }
			1 { $this.config.scanFarmType = [ScanFarmLicenseType]::Sca }
			2 { $this.config.scanFarmType = [ScanFarmLicenseType]::All }
		}

		return $true
	}

	[void]Reset(){
		$this.config.scanFarmType = [ScanFarmLicenseType]::None
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmSastLicenseFile","scanFarmType"))]
class ScanFarmSastLicense : Step {
	static [string] hidden $description = @'
The SAST Scan Farm feature is enabled using a separate license file.
'@

	ScanFarmSastLicense([Config] $config) : base(
		[ScanFarmSastLicense].Name, 
		$config,
		'Scan Farm SAST License',
		[ScanFarmSastLicense]::description,
		'Enter the path to your Scan Farm SAST license file') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmSastLicenseFile = ([PathQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmSastLicenseFile = ''
	}

	[bool]CanRun() {
		return $this.config.scanFarmType -eq [ScanFarmLicenseType]::Sast -or $this.config.scanFarmType -eq [ScanFarmLicenseType]::All
	}
}

[ConfigAttribute(("scanFarmScaLicenseFile","scanFarmType"))]
class ScanFarmScaLicense : Step {
	static [string] hidden $description = @'
The SCA Scan Farm feature is enabled using a separate license file.

Note: Your SCA license file is associated with a Black Duck-provided
SCA API endpoint upon which SCA scans depend.
'@

	ScanFarmScaLicense([Config] $config) : base(
		[ScanFarmScaLicense].Name, 
		$config,
		'Scan Farm SCA License',
		[ScanFarmScaLicense]::description,
		'Enter the path to your Scan Farm SCA license file') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmScaLicenseFile = ([PathQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmScaLicenseFile = ''
	}

	[bool]CanRun() {
		return $this.config.scanFarmType -eq [ScanFarmLicenseType]::Sca -or $this.config.scanFarmType -eq [ScanFarmLicenseType]::All
	}
}
