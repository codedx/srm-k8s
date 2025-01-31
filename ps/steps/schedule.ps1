[ConfigAttribute(("k8sProvider","useNodeSelectors"))]
class UseNodeSelectors : Step {

	static [string] hidden $description = @'
Specify whether you want to use node selectors to attract SRM 
pods to specific nodes in your cluster.

Note: When using node selectors, before installing SRM, you must label 
your nodes using the selectors you define. For example, if you specify a 
'node' selector key and a 'webapp' selector value, label your node(s) using 
this command: 

kubectl label nodes your-cluster-node-name node=webapp
'@

	UseNodeSelectors([Config] $config) : base(
		[UseNodeSelectors].Name, 
		$config,
		'Node Selectors',
		[UseNodeSelectors]::description,
		'Do you want to specify node selectors?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to define node selectors.',
			'No, I do not want to define node selectors', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useNodeSelectors = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[bool]CanRun() {
		# the tool workflows do not currently support node selectors or pod 
		# tolerations (Argo has support in the workflow spec). since most 
		# minikube clusters will be one-node clusters, avoid node selectors
		# and pod tolerations
		return $this.config.k8sProvider -ne [ProviderType]::Minikube
	}

	[void]Reset(){
		$this.config.useNodeSelectors = $false
	}
}

class KeyValueStep : Step {

	[string] $keyPrompt
	[string] $valuePrompt

	KeyValueStep([Config] $config, 
		[string] $name, [string] $title, 
		[string] $description,
		[string] $keyPrompt,
		[string] $valuePrompt) : base(
		$name, 
		$config,
		$title,
		$description,
		'') {

		$this.keyPrompt = $keyPrompt
		$this.valuePrompt = $valuePrompt
	}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object Question($prompt)
	}

	[bool]Run() {

		Write-HostSection $this.title ($this.GetMessage())

		$footer = $this.GetMessageFooter()
		if ("" -ne $footer) {
			Write-Host $footer
			Write-Host
		}

		$keyQuestion = $this.MakeQuestion($this.keyPrompt)
		$keyQuestion.allowEmptyResponse = $true

		$keyQuestion.Prompt()
		if (-not $keyQuestion.hasResponse) {
			return $false
		}
		if ($keyQuestion.isResponseEmpty) {
			return $true
		}

		$valueQuestion = $this.MakeQuestion($this.valuePrompt)
		$valueQuestion.Prompt()
		if (-not $valueQuestion.hasResponse) {
			return $false
		}

		$keyValue = [Tuple`2[string,string]]::new($keyQuestion.response, $valueQuestion.response)
		$this.HandleKeyValueResponse($keyValue)
		$this.HandleKeyValueNote($keyValue)
		return $true
	}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		throw [NotImplementedException]
	}

	[void]HandleKeyValueNote([Tuple`2[string,string]] $keyValue) {
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}
}

[ConfigAttribute(("useNodeSelectors"))]
class NodeSelectorStep : KeyValueStep {

	[string] $nodeNameExample

	NodeSelectorStep([Config] $config, [string] $name, [string] $title, [string] $description, [string] $nodeNameExample) : base(
		$config,
		$name, 
		$title,
		$description,
		'Enter the node selector key name',
		'Enter the node selector value name') {
		$this.nodeNameExample = $nodeNameExample
	}

	[void]HandleKeyValueNote([Tuple`2[string,string]] $keyValue) {
		$this.config.SetNote($this.GetType().Name, "- kubectl label nodes $($this.nodeNameExample) $($keyValue.Item1)=$($keyValue.Item2)")
	}

	[void]Reset() {
		$this.config.RemoveNote($this.GetType().Name)
	}

	[bool]CanRun() {
		return $this.config.useNodeSelectors
	}
}

[ConfigAttribute(("webNodeSelector"))]
class WebNodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for the SRM web application by entering a key and 
a value that you define. You must separately label your cluster node(s).

Note: You can use the same node selector key and value for multiple workloads.
'@

    WebNodeSelector([Config] $config) : base(
		$config,
		[WebNodeSelector].Name, 
		'SRM Web Node Selector',
		[WebNodeSelector]::description,
		'srm-web-app-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.webNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.webNodeSelector = $null
	}
}

[ConfigAttribute(("masterDatabaseNodeSelector","skipDatabase"))]
class MasterDatabaseNodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for the master database by entering a key and 
a value that you define. You must separately label your cluster node(s).

Note: You can use the same node selector key and value for multiple workloads.
'@

	MasterDatabaseNodeSelector([Config] $config) : base(
		$config,
		[MasterDatabaseNodeSelector].Name, 
		'Master Database Node Selector',
		[MasterDatabaseNodeSelector]::description,
		'master-database-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.masterDatabaseNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([NodeSelectorStep]$this).CanRun() -and -not $this.config.skipDatabase
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.masterDatabaseNodeSelector = $null
	}
}

[ConfigAttribute(("dbSlaveReplicaCount","subordinateDatabaseNodeSelector"))]
class SubordinateDatabaseNodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for the subordinate database by entering a key and 
a value that you define. You must separately label your cluster node(s).

Note: You can use the same node selector key and value for multiple workloads.
'@

	SubordinateDatabaseNodeSelector([Config] $config) : base(
		$config,
		[SubordinateDatabaseNodeSelector].Name, 
		'Subordinate Database Node Selector',
		[SubordinateDatabaseNodeSelector]::description,
		'subordinate-database-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.subordinateDatabaseNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([NodeSelectorStep]$this).CanRun() -and $this.config.dbSlaveReplicaCount -gt 0
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.subordinateDatabaseNodeSelector = $null
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceNodeSelector"))]
class ToolServiceNodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for the tool service by entering a key and 
a value that you define. You must separately label your cluster node(s).

Note: You can use the same node selector key and value for multiple workloads.
'@

	ToolServiceNodeSelector([Config] $config) : base(
		$config,
		[ToolServiceNodeSelector].Name, 
		'Tool Service Node Selector',
		[ToolServiceNodeSelector]::description,
		'tool-service-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.toolServiceNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([NodeSelectorStep]$this).CanRun() -and -not $this.config.skipToolOrchestration
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.toolServiceNodeSelector = $null
	}
}

[ConfigAttribute(("minioNodeSelector","skipMinIO","skipToolOrchestration"))]
class MinIONodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for MinIO by entering a key and a value that you 
define. You must separately label your cluster node(s).

Note: You can use the same node selector key and value for multiple workloads.
'@

	MinIONodeSelector([Config] $config) : base(
		$config,
		[MinIONodeSelector].Name, 
		'MinIO Node Selector',
		[MinIONodeSelector]::description,
		'minio-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.minioNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([NodeSelectorStep]$this).CanRun() -and -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.minioNodeSelector = $null
	}
}

[ConfigAttribute(("skipToolOrchestration","workflowControllerNodeSelector"))]
class WorkflowControllerNodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for the workflow controller by entering a key and 
a value that you define. You must separately label your cluster node(s).

Note: You can use the same node selector key and value for multiple workloads.
'@

	WorkflowControllerNodeSelector([Config] $config) : base(
		$config,
		[WorkflowControllerNodeSelector].Name, 
		'Workflow Controller Node Selector',
		[WorkflowControllerNodeSelector]::description,
		'workflow-controller-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.workflowControllerNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([NodeSelectorStep]$this).CanRun() -and -not $this.config.skipToolOrchestration
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.workflowControllerNodeSelector = $null
	}
}

[ConfigAttribute(("skipToolOrchestration","toolNodeSelector"))]
class ToolNodeSelector : NodeSelectorStep {

	static [string] hidden $description = @'
Specify a node selector for all tools by entering a key and a value that 
you define. You must separately label your cluster node(s). 

You can configure a node selector for specific projects and/or tools by 
adding the nodeSelectorKey and nodeSelectorValue fields to a SRM 
Resource Requirement - browse to the following URL for more details:

https://documentation.blackduck.com/bundle/srm/page/user_guide/Analysis/resource_requirements.html

Note: You can use the same node selector key and value for multiple workloads.
'@

	ToolNodeSelector([Config] $config) : base(
		$config,
		[ToolNodeSelector].Name, 
		'Tool Node Selector',
		[ToolNodeSelector]::description,
		'tool-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.toolNodeSelector = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([NodeSelectorStep]$this).CanRun() -and -not $this.config.skipToolOrchestration
	}

	[void]Reset(){
		([NodeSelectorStep]$this).Reset()
		$this.config.toolNodeSelector = $null
	}
}

[ConfigAttribute(("k8sProvider","useTolerations"))]
class UseTolerations : Step {

	static [string] hidden $description = @'
Specify whether you want to use node taints and tolerations to repel pods from 
specific nodes in your cluster. The tolerations you specify here will apply to 
both the NoSchedule and NoExecute effects.

Note: When using pod tolerations, before installing SRM, you must place 
taints on your nodes based on the tolerations you specify. For example, if you 
specify a 'dedicated' toleration key and a 'webapp' toleration value, apply a 
node taint using the following commands:

kubectl taint nodes your-cluster-node-name dedicated=webapp:NoSchedule
kubectl taint nodes your-cluster-node-name dedicated=webapp:NoExecute
'@

	UseTolerations([Config] $config) : base(
		[UseTolerations].Name, 
		$config,
		'Pod Tolerations',
		[UseTolerations]::description,
		'Do you want to specify pod tolerations?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to define pod tolerations.',
			'No, I do not want to define pod tolerations', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useTolerations = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[bool]CanRun() {
		# the tool workflows do not currently support node selectors or pod 
		# tolerations (Argo has support in the workflow spec). since most 
		# minikube clusters will be one-node clusters, avoid node selectors
		# and pod tolerations
		return $this.config.k8sProvider -ne [ProviderType]::Minikube
	}

	[void]Reset(){
		$this.config.useTolerations = $false
	}
}

[ConfigAttribute(("useTolerations"))]
class PodTolerationStep : KeyValueStep {

	[string] $nodeNameExample

	PodTolerationStep([Config] $config, [string] $name, [string] $title, [string] $description, [string] $nodeNameExample) : base(
		$config,
		$name, 
		$title,
		$description,
		'Enter the pod toleration key name',
		'Enter the pod toleration value name') {
		$this.nodeNameExample = $nodeNameExample
	}

	[void]HandleKeyValueNote([Tuple`2[string,string]] $keyValue) {
		$keyValueString = "$($keyValue.Item1)=$($keyValue.Item2)"
		$this.config.SetNote($this.GetType().Name, "- kubectl taint nodes $($this.nodeNameExample) $keyValueString`:NoSchedule`n- kubectl taint nodes $($this.nodeNameExample) $keyValueString`:NoExecute")
	}

	[bool]CanRun() {
		return $this.config.useTolerations
	}

	[void]Reset() {
		$this.config.RemoveNote($this.GetType().Name)
	}
}

[ConfigAttribute(("webNoScheduleExecuteToleration"))]
class WebTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for the SRM web application by entering a key 
and a value that you define. You must separately apply a taint to your 
cluster node(s). The key and value you define will be associated with the 
NoSchedule and NoExecute effects.

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	WebTolerations([Config] $config) : base(
		$config,
		[WebTolerations].Name, 
		'SRM Web Pod Toleration',
		[WebTolerations]::description,
		'srm-web-app-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.webNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.webNoScheduleExecuteToleration = $null
	}
}

[ConfigAttribute(("masterDatabaseNoScheduleExecuteToleration","skipDatabase"))]
class MasterDatabaseTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for the master database by entering a key 
and a value that you define. You must separately apply a taint to your 
cluster node(s). The key and value you define will be associated with the 
NoSchedule and NoExecute effects.

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	MasterDatabaseTolerations([Config] $config) : base(
		$config,
		[MasterDatabaseTolerations].Name, 
		'Master Database Pod Toleration',
		[MasterDatabaseTolerations]::description,
		'master-database-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.masterDatabaseNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([PodTolerationStep]$this).CanRun() -and -not $this.config.skipDatabase
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.masterDatabaseNoScheduleExecuteToleration = $null
	}
}

[ConfigAttribute(("dbSlaveReplicaCount","subordinateDatabaseNoScheduleExecuteToleration"))]
class SubordinateDatabaseTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for the subordinate database by entering a key 
and a value that you define. You must separately apply a taint to your 
cluster node(s). The key and value you define will be associated with the 
NoSchedule and NoExecute effects.

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	SubordinateDatabaseTolerations([Config] $config) : base(
		$config,
		[SubordinateDatabaseTolerations].Name, 
		'Subordinate Database Pod Toleration',
		[SubordinateDatabaseTolerations]::description,
		'subordinate-database-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.subordinateDatabaseNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([PodTolerationStep]$this).CanRun() -and $this.config.dbSlaveReplicaCount -gt 0
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.subordinateDatabaseNoScheduleExecuteToleration = $null
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceNoScheduleExecuteToleration"))]
class ToolServiceTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for the tool service by entering a key 
and a value that you define. You must separately apply a taint to your 
cluster node(s). The key and value you define will be associated with the 
NoSchedule and NoExecute effects.

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	ToolServiceTolerations([Config] $config) : base(
		$config,
		[ToolServiceTolerations].Name, 
		'Tool Service Pod Toleration',
		[ToolServiceTolerations]::description,
		'tool-service-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.toolServiceNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([PodTolerationStep]$this).CanRun() -and -not $this.config.skipToolOrchestration
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.toolServiceNoScheduleExecuteToleration = $null
	}
}

[ConfigAttribute(("minioNoScheduleExecuteToleration","skipMinIO","skipToolOrchestration"))]
class MinIOTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for the MinIO by entering a key and a value that 
you define. You must separately apply a taint to your cluster node(s). 
The key and value you define will be associated with the NoSchedule and 
NoExecute effects.

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	MinIOTolerations([Config] $config) : base(
		$config,
		[MinIOTolerations].Name, 
		'MinIO Pod Toleration',
		[MinIOTolerations]::description,
		'minio-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.minioNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([PodTolerationStep]$this).CanRun() -and -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.minioNoScheduleExecuteToleration = $null
	}
}

[ConfigAttribute(("skipToolOrchestration","workflowControllerNoScheduleExecuteToleration"))]
class WorkflowControllerTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for the workflow controller by entering a key 
and a value that you define. You must separately apply a taint to your 
cluster node(s). The key and value you define will be associated with the 
NoSchedule and NoExecute effects.

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	WorkflowControllerTolerations([Config] $config) : base(
		$config,
		[WorkflowControllerTolerations].Name, 
		'Workflow Controller Pod Toleration',
		[WorkflowControllerTolerations]::description,
		'workflow-controller-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.workflowControllerNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([PodTolerationStep]$this).CanRun() -and -not $this.config.skipToolOrchestration
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.workflowControllerNoScheduleExecuteToleration = $null
	}
}

[ConfigAttribute(("skipToolOrchestration","toolNoScheduleExecuteToleration"))]
class ToolTolerations : PodTolerationStep {

	static [string] hidden $description = @'
Specify a pod toleration for all tools by entering a key and a value that 
you define. You must separately apply a taint to your cluster node(s). 
The key and value you define will be associated with the NoSchedule 
and NoExecute effects.

You can configure a pod toleration for specific projects and/or tools by 
adding the podTolerationKey and podTolerationValue fields to a SRM 
Resource Requirement - browse to the following URL for more details:

https://codedx.com/Documentation/UserGuide.html#ResourceRequirements

Note: You can use the same pod toleration key and value for multiple workloads.
'@

	ToolTolerations([Config] $config) : base(
		$config,
		[ToolTolerations].Name, 
		'Tool Pod Toleration',
		[ToolTolerations]::description,
		'tool-node') {}

	[bool]HandleKeyValueResponse([Tuple`2[string,string]] $keyValue) {
		$this.config.toolNoScheduleExecuteToleration = [KeyValue]::new($keyValue.Item1, $keyValue.Item2)
		return $true
	}

	[bool]CanRun() {
		return ([PodTolerationStep]$this).CanRun() -and -not $this.config.skipToolOrchestration
	}

	[void]Reset(){
		([PodTolerationStep]$this).Reset()
		$this.config.toolNoScheduleExecuteToleration = $null
	}
}
