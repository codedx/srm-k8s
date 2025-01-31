class Welcome : Step {

	Welcome([Config] $config) : base(
		[Welcome].Name,
		$config,
		'',
		'',
		'') {}

	[bool]Run() {
        Write-Host '  ______       _______         ____    ____  '
        Write-Host '.'' ____ \     |_   __ \       |_   \  /   _|'
        Write-Host '| (___ \_|      | |__) |        |   \/   |   '
        Write-Host ' _.____`.       |  __ /         | |\  /| |   '
        Write-Host '| \____) |     _| |  \ \_      _| |_\/_| |_  '
        Write-Host ' \______.''    |____| |___|    |_____||_____|'
		Write-Host @'

Welcome to the Software Risk Manager Helm Prep Wizard!

You will use Helm to deploy SRM. This wizard helps you
specify your desired SRM deployment configuration by
generating a config.json file that you can use with
the Helm Prep script to stage your helm deployment.

Note: Once you have your config.json file, you will
not need to rerun this wizard.

'@
		Read-HostEnter
		return $true
	}
}

class About : Step {

	static [string] hidden $description = @'
This wizard will ask you a series of questions based on the SRM features
you plan to deploy. Follow this link to read the SRM Deployment Guide:
https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md

You should complete any required pre-work before continuing.

If you need to return to a previous screen to correct an error or revisit
a question, enter 'B' to choose the "Back to Previous Step" option. If
you are responding to a prompt that is not multiple choice,
press Enter to reveal the "Back to Previous Step" choice.
'@

	static [string] hidden $previousConfigWarning = @'
Note: This wizard will display parameters from your previous configuration
file on subsequent screens for your reference. These may include passwords
and keys shown in plaintext.
'@

	About([Config] $config) : base(
		[About].Name,
		$config, 
		'About', 
		[About]::description, 
		'Do you want to continue?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, 
			[tuple]::create('&Yes', 'Yes, I want to continue.'),
			-1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}

	[string]GetMessage() {

		[string] $msg = [About]::description
		if ($null -ne $this.previousConfig) {
			$msg += "`n`n" + [About]::previousConfigWarning
		}
		return $msg
	}
}

[ConfigAttribute(("workDir"))]
class WorkDir : Step {

	static [string] hidden $description = @'
Specify a directory to store files generated during the setup process. Files 
in your work directory may contain data that should be kept private.
'@

	[string] $homeDirectory = $HOME

	WorkDir([Config] $config) : base(
		[WorkDir].Name, 
		$config,
		'Work Directory',
		[WorkDir]::description,
		"Enter a directory or press Enter to accept the default ($HOME/.k8s-srm)") {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [Question]$question
		$this.config.workDir = $q.isResponseEmpty ? "$($this.homeDirectory)/.k8s-srm" : $q.response

		if (-not (Test-Path $this.config.workDir -Type Container)) {
			try {
				New-Item -ItemType Directory $this.config.workDir | out-null
			} catch {
				Write-Host "Cannot create directory $($this.config.workDir): " $_
				$this.config.workDir = ''
				return $false
			}
		}

		return $true
	}
}

class Abort : Step {

	Abort([Config] $config) : base(
		[Abort].Name, 
		$config,
		'',
		'',
		'') {}

	[bool]Run() {
		Write-Host 'Setup aborted'
		return $true
	}
}
