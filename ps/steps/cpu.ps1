[ConfigAttribute(("useCPUDefaults"))]
class DefaultCPU : Step {

	static [string] hidden $description = @'
Specify whether you want to make CPU reservations. A reservation will ensure 
your SRM workloads are placed on a node with sufficient resources. The 
recommended values are displayed below. Alternatively, you can skip making 
reservations or you can specify each reservation individually.
'@

	static [string] hidden $notes = @'
Note: You must make sure that your cluster has adequate CPU resources to 
accommodate the resource requirements you specify. Failure to do so 
will cause SRM pods to get stuck in a Pending state.
'@

	DefaultCPU([Config] $config) : base(
		[DefaultCPU].Name, 
		$config,
		'CPU Reservations',
		'',
		'Make CPU reservations?') { }

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
		$this.config.useCPUDefaults = $applyDefaults
		return $true
	}

	[void]Reset(){
		$this.config.useCPUDefaults = $false
	}

	[Step[]] GetSteps() {

		$steps = @()
		[WebCPU],[MasterDatabaseCPU],[SubordinateDatabaseCPU],[ToolServiceCPU],[MinIOCPU],[WorkflowCPU] | ForEach-Object {
			$step = new-object -type $_ -args $this.config
			if ($step.CanRun()) {
				$steps += $step
			}
		}
		return $steps
	}

	[string]GetMessage() {

		$message = [DefaultCPU]::description + "`n`n" + [DefaultCPU]::notes
		$message += "`n`nHere are the recommended values (1000m = 1 vCPU):`n`n"
		$this.GetSteps() | ForEach-Object {
			$default = $_.GetDefault()
			if ('' -ne $default) {
				$message += "    {0}: {1}`n" -f (([CPUStep]$_).title,$default)
			}
		}
		return $message
	}

	[bool]CanRun() {
		return -not $this.config.IsSystemSizeSpecified()
	}
}

[ConfigAttribute(("useCPUDefaults"))]
class CPUStep : Step {

	static [string] hidden $description = @'
Specify the amount of CPU to reserve in millicpu/millicore where 1000m is 
equal to 1 vCPU. Making a reservation will set the Kubernetes resource 
limit and request parameters to the same value.

2000m =  2 vCPU
1000m =  1 vCPU
 500m = .5 vCPU

Pods will not be evicted if CPU usage is permitted to exceed the 
reservation.

Note: You can skip making a reservation by accepting the default value.
'@

	CPUStep([string]  $name, 
		[string]      $title,
		[Config] $config) : base($name, 
			$config,
			$title,
			[CPUStep]::description,
			'Enter CPU reservation in millicpus/millicores (e.g., 1000m)') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		$question.validationExpr = '^[1-9]\d*m?$'
		$question.validationHelp = 'You entered an invalid value. Enter a value in millicpu/millcores such as 1000m'
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {

		if (-not $question.isResponseEmpty -and -not $question.response.endswith('m')) {
			$question.response += 'm'
		}

		$response = $question.response
		if ($question.isResponseEmpty) {
			$response = $this.GetDefault()
		}

		return $this.HandleCpuResponse($response)
	}

	[bool]HandleCpuResponse([string] $cpu) {
		throw [NotImplementedException]
	}

	[bool]CanRun() {
		return -not $this.config.useCPUDefaults
	}
}

[ConfigAttribute(("webCPUReservation"))]
class WebCPU : CPUStep {

	WebCPU([Config] $config) : base(
		[WebCPU].Name, 
		'SRM Web CPU Reservation',
		$config) {}

	[bool]HandleCpuResponse([string] $cpu) {
		$this.config.webCPUReservation = $cpu
		return $true
	}

	[void]Reset(){
		$this.config.webCPUReservation = ''
	}

	[void]ApplyDefault() {
		$this.config.webCPUReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '4000m'
	}
}

[ConfigAttribute(("dbMasterCPUReservation","skipDatabase"))]
class MasterDatabaseCPU : CPUStep {

	MasterDatabaseCPU([Config] $config) : base([MasterDatabaseCPU].Name, 'Master Database CPU Reservation', $config) {}

	[bool]HandleCpuResponse([string] $cpu) {
		$this.config.dbMasterCPUReservation = $cpu
		return $true
	}

	[void]Reset(){
		$this.config.dbMasterCPUReservation = ''
	}

	[bool]CanRun() {
		return ([CPUStep]$this).CanRun() -and (-not ($this.config.skipDatabase))
	}

	[void]ApplyDefault() {
		$this.config.dbMasterCPUReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '4000m'
	}
}

[ConfigAttribute(("dbSlaveCPUReservation","dbSlaveReplicaCount","skipDatabase"))]
class SubordinateDatabaseCPU : CPUStep {

	SubordinateDatabaseCPU([Config] $config) : base([SubordinateDatabaseCPU].Name, 'Subordinate Database CPU Reservation', $config) {}

	[bool]HandleCpuResponse([string] $cpu) {
		$this.config.dbSlaveCPUReservation = $cpu
		return $true
	}

	[void]Reset(){
		$this.config.dbSlaveCPUReservation = ''
	}

	[bool]CanRun() {
		return ([CPUStep]$this).CanRun() -and (-not ($this.config.skipDatabase)) -and $this.config.dbSlaveReplicaCount -gt 0
	}
	
	[void]ApplyDefault() {
		$this.config.dbSlaveCPUReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '2000m'
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceCPUReservation"))]
class ToolServiceCPU : CPUStep {

	ToolServiceCPU([Config] $config) : base([ToolServiceCPU].Name, 'Tool Service CPU Reservation', $config) {}

	[bool]HandleCpuResponse([string] $cpu) {
		$this.config.toolServiceCPUReservation = $cpu
		return $true
	}

	[void]Reset(){
		$this.config.toolServiceCPUReservation = ''
	}

	[bool]CanRun() {
		return ([CPUStep]$this).CanRun() -and (-not ($this.config.skipToolOrchestration))
	}

	[void]ApplyDefault() {
		$this.config.toolServiceCPUReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '1000m'
	}
}

[ConfigAttribute(("minioCPUReservation","skipMinIO","skipToolOrchestration"))]
class MinIOCPU : CPUStep {

	MinIOCPU([Config] $config) : base([MinIOCPU].Name, 'MinIO CPU Reservation', $config) {}

	[bool]HandleCpuResponse([string] $cpu) {
		$this.config.minioCPUReservation = $cpu
		return $true
	}

	[void]Reset(){
		$this.config.minioCPUReservation = ''
	}

	[bool]CanRun() {
		return ([CPUStep]$this).CanRun() -and -not $this.config.skipToolOrchestration -and -not ($this.config.skipMinIO)
	}

	[void]ApplyDefault() {
		$this.config.minioCPUReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '2000m'
	}
}

[ConfigAttribute(("skipToolOrchestration","workflowCPUReservation"))]
class WorkflowCPU : CPUStep {

	WorkflowCPU([Config] $config) : base([WorkflowCPU].Name, 'Workflow Controller CPU Reservation', $config) {}

	[bool]HandleCpuResponse([string] $cpu) {
		$this.config.workflowCPUReservation = $cpu
		return $true
	}

	[void]Reset(){
		$this.config.workflowCPUReservation = ''
	}

	[void]ApplyDefault() {
		$this.config.workflowCPUReservation = $this.GetDefault()
	}

	[bool]CanRun() {
		return ([CPUStep]$this).CanRun() -and (-not ($this.config.skipToolOrchestration))
	}

	[string]GetDefault() {
		return '500m'
	}
}
