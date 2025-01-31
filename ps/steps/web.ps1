[ConfigAttribute(("useTriageAssistant"))]
class UseTriageAssistant : Step {

	static [string] hidden $description = @'
Do you plan to enable the SRM Triage Assistant? The Machine Learning 
Triage Assistant requires additional CPU and memory.
'@

	UseTriageAssistant([Config] $config) : base(
		[UseTriageAssistant].Name, 
		$config,
		'Use Triage Assistant',
		[UseTriageAssistant]::description,
		'Will your SRM deployment include the Triage Assistant?') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I plan to enable the SRM Triage Assistant',
			'No, I don''t plan to enable the SRM Triage Assistant', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useTriageAssistant = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.useTriageAssistant = $false
	}
}
