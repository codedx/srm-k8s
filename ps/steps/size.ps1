[ConfigAttribute(("systemSize"))]
class Size : Step {

	static [string] hidden $description = @'
Specify the size of your Software Risk Manager deployment using
the following guidelines:

SIZE        | TOTAL PROJECTS | DAILY ANALYSES | CONCURRENT ANALYSES
-------------------------------------------------------------------
Small                1 - 100            1,000                     8
Medium           100 - 2,000            2,000                    16
Large         2,000 - 10,000           10,000                    32
Extra Large          10,000+          10,000+                    64

Note: Select "Unspecified" if you want to enter CPU and memory
requirements on a per-component basis (not recommended).
'@

	Size([Config] $config) : base(
		[Size].Name, 
		$config,
		'Deployment Size',
		[Size]::description,
		'What is your deployment size?') { }

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Unspecified', 'Size is unknown; specify CPU and memory per component'),
			[tuple]::create('&Small', 'Total projects between 1 and 100 with 1,000 daily analyses (8 concurrent)'),
			[tuple]::create('&Medium', 'Total projects between 100 and 2000 with 2,000 daily analyses (16 concurrent)'),
			[tuple]::create('&Large', 'Total projects between 2,000 and 10,000 with 10,000 daily analyses (32 concurrent)'),
			[tuple]::create('&Extra Large', 'Total projects in excess of 10,000 with more than 10,000 daily analyses (64 concurrent)')), 1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.systemSize = [SystemSize]::Unspecified }
			1 { $this.config.systemSize = [SystemSize]::Small }
			2 { $this.config.systemSize = [SystemSize]::Medium }
			3 { $this.config.systemSize = [SystemSize]::Large }
			4 { $this.config.systemSize = [SystemSize]::ExtraLarge }
		}
		return $true
	}

	[void]Reset(){
		$this.config.systemSize = [SystemSize]::Unspecified
	}
}
