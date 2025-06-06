[ConfigAttribute(("useEphemeralStorageDefaults"))]
class DefaultEphemeralStorage : Step {

	static [string] hidden $description = @'
Specify whether you want to make ephemeral storage reservations. A reservation 
will ensure your SRM workloads are placed on a node with sufficient 
resources. The recommended values are displayed below. Alternatively, you can 
skip making reservations or you can specify each reservation individually.
'@

	static [string] hidden $notes = @'
Note: You must make sure that your cluster has adequate storage resources to 
accommodate the resource requirements you specify. Failure to do so 
will cause SRM pods to get stuck in a Pending state.
'@

	DefaultEphemeralStorage([Config] $config) : base(
		[DefaultEphemeralStorage].Name, 
		$config,
		'Ephemeral Storage Reservations',
		'',
		'Use default ephemeral storage reservations?') { }

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
		$this.config.useEphemeralStorageDefaults = $applyDefaults
		return $true
	}

	[void]Reset(){
		$this.config.useEphemeralStorageDefaults = $false
	}

	[Step[]] GetSteps() {

		$steps = @()
		[WebEphemeralStorage],[MasterDatabaseEphemeralStorage],[SubordinateDatabaseEphemeralStorage],[ToolServiceEphemeralStorage],[MinIOEphemeralStorage],[WorkflowEphemeralStorage] | ForEach-Object {
			$step = new-object -type $_ -args $this.config
			if ($step.CanRun()) {
				$steps += $step
			}
		}
		return $steps
	}

	[string]GetMessage() {

		$message = [DefaultEphemeralStorage]::description + "`n`n" + [DefaultEphemeralStorage]::notes
		$message += "`n`nHere are the defaults (1024Mi =  1 Gibibyte):`n`n"
		$this.GetSteps() | ForEach-Object {
			$default = $_.GetDefault()
			if ('' -ne $default) {
				$message += "    {0}: {1}`n" -f (([EphemeralStorageStep]$_).title,$default)
			}
		}
		return $message
	}
}

[ConfigAttribute(("useEphemeralStorageDefaults"))]
class EphemeralStorageStep : Step {

	static [string] hidden $description = @'
Specify the amount of ephemeral storage to reserve in mebibytes (Mi) where 
1024 mebibytes is 1 gibibytes (Gi). Ephemeral storage is used by pods for 
logging, so high system activity may require more storage capacity. Making 
a reservation will set the Kubernetes resource limit and request 
parameters to the same value.

2048Mi =  2 Gibibyte
1024Mi =  1 Gibibyte
 512Mi = .5 Gibibyte

Pods may be evicted if ephemeral storage usage exceeds the reservation.

Note: You can skip making a reservation by accepting the default value.
'@

	[string] $title
	[string] $storage

	EphemeralStorageStep([string] $name, 
		[string] $title, 
		[Config] $config) : base($name, 
			$config,
			$title,
			[EphemeralStorageStep]::description,
			'Enter ephemeral storage reservation in mebibytes (e.g., 1024Mi)') {
		$this.title = $title
	}

	[IQuestion]MakeQuestion([string] $prompt) {

		$question = new-object Question($prompt)
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

		return $this.HandleStorageResponse($response)		
	}

	[bool]HandleStorageResponse([string] $storage) {
		throw [NotImplementedException]
	}

	[bool]CanRun() {
		return -not $this.config.useEphemeralStorageDefaults
	}
}

[ConfigAttribute(("webEphemeralStorageReservation"))]
class WebEphemeralStorage : EphemeralStorageStep {

	WebEphemeralStorage([Config] $config) : base(
		[WebEphemeralStorage].Name, 
		'SRM Web Ephemeral Storage Reservation', 
		$config) {}

	[bool]HandleStorageResponse([string] $storage) {
		$this.config.webEphemeralStorageReservation = $storage
		return $true
	}

	[void]Reset(){
		$this.config.webEphemeralStorageReservation = $this.GetDefault()
	}

	[void]ApplyDefault() {
		$this.config.webEphemeralStorageReservation = $this.GetDefault()
	}

	[string]GetDefault() {
		return '2868Mi'
	}
}

[ConfigAttribute(("dbMasterEphemeralStorageReservation","skipDatabase"))]
class MasterDatabaseEphemeralStorage : EphemeralStorageStep {

	MasterDatabaseEphemeralStorage([Config] $config) : base(
		[MasterDatabaseEphemeralStorage].Name, 
		'Master Database Ephemeral Storage Reservation', 
		$config) {}

	[bool]HandleStorageResponse([string] $storage) {
		$this.config.dbMasterEphemeralStorageReservation = $storage
		return $true
	}

	[void]Reset(){
		$this.config.dbMasterEphemeralStorageReservation = ''
	}

	[bool]CanRun() {
		return ([EphemeralStorageStep]$this).CanRun() -and (-not ($this.config.skipDatabase))
	}

	[void]ApplyDefault() {
		$this.config.dbMasterEphemeralStorageReservation = $this.GetDefault()
	}
}

[ConfigAttribute(("dbSlaveEphemeralStorageReservation","dbSlaveReplicaCount","skipDatabase"))]
class SubordinateDatabaseEphemeralStorage : EphemeralStorageStep {

	SubordinateDatabaseEphemeralStorage([Config] $config) : base(
		[SubordinateDatabaseEphemeralStorage].Name, 
		'Subordinate Database Ephermal Storage Reservation', 
		$config) {}

	[bool]HandleStorageResponse([string] $storage) {
		$this.config.dbSlaveEphemeralStorageReservation = $storage
		return $true
	}

	[void]Reset(){
		$this.config.dbSlaveEphemeralStorageReservation = ''
	}

	[bool]CanRun() {
		return ([EphemeralStorageStep]$this).CanRun() -and (-not ($this.config.skipDatabase)) -and $this.config.dbSlaveReplicaCount -gt 0
	}

	[void]ApplyDefault() {
		$this.config.dbSlaveEphemeralStorageReservation = $this.GetDefault()
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceEphemeralStorageReservation"))]
class ToolServiceEphemeralStorage : EphemeralStorageStep {

	ToolServiceEphemeralStorage([Config] $config) : base(
		[ToolServiceEphemeralStorage].Name, 
		'Tool Service Ephemeral Storage Reservation', 
		$config) {}

	[bool]HandleStorageResponse([string] $storage) {
		$this.config.toolServiceEphemeralStorageReservation = $storage
		return $true
	}

	[void]Reset(){
		$this.config.toolServiceEphemeralStorageReservation = ''
	}

	[bool]CanRun() {
		return ([EphemeralStorageStep]$this).CanRun() -and (-not ($this.config.skipToolOrchestration))
	}

	[void]ApplyDefault() {
		$this.config.toolServiceEphemeralStorageReservation = $this.GetDefault()
	}
}

[ConfigAttribute(("minioEphemeralStorageReservation","skipMinIO","skipToolOrchestration"))]
class MinIOEphemeralStorage : EphemeralStorageStep {

	MinIOEphemeralStorage([Config] $config) : base(
		[MinIOEphemeralStorage].Name, 
		'MinIO Ephemeral Storage Reservation', 
		$config) {}

	[bool]HandleStorageResponse([string] $storage) {
		$this.config.minioEphemeralStorageReservation = $storage
		return $true
	}

	[void]Reset(){
		$this.config.minioEphemeralStorageReservation = ''
	}

	[bool]CanRun() {
		return ([EphemeralStorageStep]$this).CanRun() -and -not $this.config.skipToolOrchestration -and -not ($this.config.skipMinIO)
	}

	[void]ApplyDefault() {
		$this.config.minioEphemeralStorageReservation = $this.GetDefault()
	}
}

[ConfigAttribute(("skipToolOrchestration","workflowEphemeralStorageReservation"))]
class WorkflowEphemeralStorage : EphemeralStorageStep {

	WorkflowEphemeralStorage([Config] $config) : base(
		[WorkflowEphemeralStorage].Name, 
		'Workflow Controller Ephemeral Storage Reservation', 
		$config) {}

	[bool]HandleStorageResponse([string] $storage) {
		$this.config.workflowEphemeralStorageReservation = $storage
		return $true
	}

	[void]Reset(){
		$this.config.workflowEphemeralStorageReservation = ''
	}

	[void]ApplyDefault() {
		$this.config.workflowEphemeralStorageReservation = $this.GetDefault()
	}

	[bool]CanRun() {
		return ([EphemeralStorageStep]$this).CanRun() -and (-not ($this.config.skipToolOrchestration))
	}
}
