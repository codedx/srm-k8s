[ConfigAttribute(("skipToolOrchestration"))]
class UseToolOrchestration : Step {

	static [string] hidden $description = @'
SRM can orchestrate analyses that run on your Kubernetes cluster. The Tool 
Orchestration feature is a separately licensed component.
'@

	UseToolOrchestration([Config] $config) : base(
		[UseToolOrchestration].Name, 
		$config,
		'Tool Orchestration',
		[UseToolOrchestration]::description,
		'Install Tool Orchestration Components?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I have an SRM license that includes Tool Orchestration', 
			'No, I don''t want to use Tool Orchestration at this time', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.skipToolOrchestration = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.skipToolOrchestration = $false
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceReplicas"))]
class ToolServiceReplicaCount : Step {

	static [string] hidden $description = @'
Specify the number of tool service instances that you want to run. Having more 
than one tool service can keep the service online when a single instance fails.
You must run at least one service instance.
'@

	ToolServiceReplicaCount([Config] $config) : base(
		[ToolServiceReplicaCount].Name, 
		$config,
		'Tool Service Replicas',
		[ToolServiceReplicaCount]::description,
		'Enter the number of tool service replicas') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object IntegerQuestion($prompt, 1, ([int]::maxvalue), $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.toolServiceReplicas = ([IntegerQuestion]$question).intResponse
		return $true
	}

	[void]Reset(){
		$this.config.toolServiceReplicas = [Config]::toolServiceReplicasDefault
	}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration -and -not $this.config.IsSystemSizeSpecified()
	}
}
