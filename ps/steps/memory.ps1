[ConfigAttribute(("useMemoryDefaults"))]
class DefaultMemory : Step {

	static [string] hidden $description = @'
Specify whether you want to make memory reservations. A reservation will 
ensure your SRM workloads are placed on a node with sufficient resources. 
The recommended values are displayed below. Alternatively, you can skip making 
reservations or you can specify each reservation individually.
'@

	static [string] hidden $notes = @'
Note: You must make sure that your cluster has adequate memory resources to 
accommodate the resource requirements you specify. Failure to do so 
will cause SRM pods to get stuck in a Pending state.
'@

	DefaultMemory([Config] $config) : base(
		[DefaultMemory].Name, 
		$config,
		'Memory Reservations',
		'',
		'Make memory reservations?') { }

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Use Recommended', 'Use recommended reservations'),
			[tuple]::create('&Custom', 'Make reservations on a per-component basis')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$mq = [MultipleChoiceQuestion]$question
		$applyDefaults = $mq.choice -eq 0
		if ($applyDefaults) {
			$this.GetSteps() | ForEach-Object {
				$_.ApplyDefault()
			}
		}
		$this.config.useMemoryDefaults = $applyDefaults
		return $true
	}

	[void]Reset(){
		$this.config.useMemoryDefaults = $false
	}

	[Step[]] GetSteps() {

		$steps = @()
		[WebMemory],[MasterDatabaseMemory],[SubordinateDatabaseMemory],[ToolServiceMemory],[MinIOMemory],[WorkflowMemory] | ForEach-Object {
			$step = new-object -type $_ -args $this.config
			if ($step.CanRun()) {
				$steps += $step
			}
		}
		return $steps
	}

	[string]GetMessage() {

		$message = [DefaultMemory]::description + "`n`n" + [DefaultMemory]::notes
		$message += "`n`nHere are the defaults (1024Mi =  1 Gibibyte):`n`n"
		$this.GetSteps() | ForEach-Object {
			$default = $_.GetDefault()
			if ('' -ne $default) {
				$message += "    {0}: {1}`n" -f (([MemoryStep]$_).title,$default)
			}
		}
		return $message
	}

	[bool]CanRun() {
		return -not $this.config.IsSystemSizeSpecified()
	}
}

[ConfigAttribute(("useMemoryDefaults"))]
class MemoryStep : Step {

	static [string] hidden $description = @'
Specify the amount of memory to reserve in mebibytes (Mi) where 1024 mebibytes 
is 1 gibibytes (Gi). Making a reservation will set the Kubernetes resource 
limit and request parameters to the same value.

2048Mi =  2 Gibibyte
1024Mi =  1 Gibibyte
 512Mi = .5 Gibibyte

Pods may be evicted if memory usage exceeds the reservation.

Note: You can skip making a reservation by accepting the default value.
'@

	MemoryStep([string] $name, 
		[string] $title, 
		[Config] $config) : base($name, 
			$config,
			$title,
			[MemoryStep]::description,
			'Enter memory reservation in mebibytes (e.g., 500Mi)') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object Question('Enter memory reservation in mebibytes (e.g., 500Mi)')
		$question.allowEmptyResponse = $true
		$question.validationExpr = '^[1-9]\d*(?:Mi)?$'
		$question.validationHelp = 'You entered an invalid value. Enter a value in mebibytes such as 1024Mi'
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {

		if (-not $question.isResponseEmpty -and -not $question.response.endswith('Mi')) {
			$question.response += 'Mi'
		}

		$response = $question.response
		if ($question.isResponseEmpty) {
			$response = $this.GetDefault()
		}

		return $this.HandleMemoryResponse($response)
	}

	[bool]HandleMemoryResponse([string] $cpu) {
		throw [NotImplementedException]
	}

	[bool]CanRun() {
		return -not $this.config.useMemoryDefaults
	}
}

[ConfigAttribute(("webMemoryReservation"))]
class WebMemory : MemoryStep {

	WebMemory([Config] $config) : base(
		[WebMemory].Name, 
		'SRM Web Memory Reservation', 
		$config) {}

	[bool]HandleMemoryResponse([string] $memory) {
		$this.config.webMemoryReservation = $memory
		return $true
	}

	[void]Reset(){
		$this.config.webMemoryReservation = ''
	}

	[void]ApplyDefault() {
		$this.config.webMemoryReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '16384Mi'
	}
}

[ConfigAttribute(("dbMasterMemoryReservation","skipDatabase"))]
class MasterDatabaseMemory : MemoryStep {

	MasterDatabaseMemory([Config] $config) : base(
		[MasterDatabaseMemory].Name, 
		'Master Database Memory Reservation', 
		$config) {}

	[bool]HandleMemoryResponse([string] $memory) {
		$this.config.dbMasterMemoryReservation = $memory
		return $true
	}

	[void]Reset(){
		$this.config.dbMasterMemoryReservation = ''
	}

	[bool]CanRun() {
		return ([MemoryStep]$this).CanRun() -and (-not ($this.config.skipDatabase))
	}

	[void]ApplyDefault() {
		$this.config.dbMasterMemoryReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '16384Mi'
	}
}

[ConfigAttribute(("dbSlaveMemoryReservation","dbSlaveReplicaCount","skipDatabase"))]
class SubordinateDatabaseMemory : MemoryStep {

	SubordinateDatabaseMemory([Config] $config) : base(
		[SubordinateDatabaseMemory].Name, 
		'Subordinate Database Memory Reservation', 
		$config) {}

	[bool]HandleMemoryResponse([string] $memory) {
		$this.config.dbSlaveMemoryReservation = $memory
		return $true
	}

	[void]Reset(){
		$this.config.dbSlaveMemoryReservation = ''
	}

	[bool]CanRun() {
		return ([MemoryStep]$this).CanRun() -and (-not ($this.config.skipDatabase)) -and $this.config.dbSlaveReplicaCount -gt 0
	}

	[void]ApplyDefault() {
		$this.config.dbSlaveMemoryReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '8192Mi'
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceMemoryReservation"))]
class ToolServiceMemory : MemoryStep {

	ToolServiceMemory([Config] $config) : base(
		[ToolServiceMemory].Name, 
		'Tool Service Memory Reservation', 
		$config) {}

	[bool]HandleMemoryResponse([string] $memory) {
		$this.config.toolServiceMemoryReservation = $memory
		return $true
	}

	[void]Reset(){
		$this.config.toolServiceMemoryReservation = ''
	}

	[bool]CanRun() {
		return ([MemoryStep]$this).CanRun() -and (-not ($this.config.skipToolOrchestration))
	}

	[void]ApplyDefault() {
		$this.config.toolServiceMemoryReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '1024Mi'
	}
}

[ConfigAttribute(("minioMemoryReservation","skipMinIO","skipToolOrchestration"))]
class MinIOMemory : MemoryStep {

	MinIOMemory([Config] $config) : base(
		[MinIOMemory].Name, 
		'MinIO Memory Reservation', 
		$config) {}

	[bool]HandleMemoryResponse([string] $memory) {
		$this.config.minioMemoryReservation = $memory
		return $true
	}

	[void]Reset(){
		$this.config.minioMemoryReservation = ''
	}

	[bool]CanRun() {
		return ([MemoryStep]$this).CanRun() -and -not $this.config.skipToolOrchestration -and -not ($this.config.skipMinIO)
	}

	[void]ApplyDefault() {
		$this.config.minioMemoryReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '5120Mi'
	}
}

[ConfigAttribute(("skipToolOrchestration","workflowMemoryReservation"))]
class WorkflowMemory : MemoryStep {

	WorkflowMemory([Config] $config) : base(
		[WorkflowMemory].Name, 
		'Workflow Controller Memory Reservation', 
		$config) {}

	[bool]HandleMemoryResponse([string] $memory) {
		$this.config.workflowMemoryReservation = $memory
		return $true
	}

	[void]Reset(){
		$this.config.workflowMemoryReservation = ''
	}

	[void]ApplyDefault() {
		$this.config.workflowMemoryReservation = $this.GetDefault()
	}

	[bool]CanRun() {
		return ([MemoryStep]$this).CanRun() -and (-not ($this.config.skipToolOrchestration))
	}

	[string]GetDefault() {
		return '500Mi'
	}
}
