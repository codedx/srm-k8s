[ConfigAttribute(("createSCCs","k8sProvider"))]
class ChooseEnvironment : Step {

	static [string] hidden $description = @'
Specify your Kubernetes provider so that the setup script can make options 
available for your type of Kubernetes cluster. 

If your Kubernetes provider is not listed below, select the 'Other' option.
'@

	ChooseEnvironment([Config] $config) : base(
		[ChooseEnvironment].Name, 
		$config,
		'Kubernetes Environment',
		[ChooseEnvironment]::description,
		'Where are you deploying SRM?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Minikube',  'Use Minikube for eval/test/dev purposes'),
			[tuple]::create('&AKS',       'Use Microsoft''s Azure Kubernetes Service (AKS)'),
			[tuple]::create('&EKS',       'Use Amazon''s Elastic Kubernetes Service (EKS)'),
			[tuple]::create('Open&Shift', 'Use OpenShift 4'),
			[tuple]::create('&Other',     'Use a different Kubernetes provider')), -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.k8sProvider = [ProviderType]::Minikube }
			1 { $this.config.k8sProvider = [ProviderType]::Aks }
			2 { $this.config.k8sProvider = [ProviderType]::Eks }
			3 { $this.config.k8sProvider = [ProviderType]::OpenShift }
			4 { $this.config.k8sProvider = [ProviderType]::Other }
		}

		$usingOpenShift = $this.config.k8sProvider -eq [ProviderType]::OpenShift
		$this.config.createSCCs = $usingOpenShift

		return $true
	}

	[void]Reset(){
		$this.config.k8sProvider = [ProviderType]::Other
		$this.config.createSCCs = $false
	}
}

[ConfigAttribute(("kubeApiTargetPort","skipNetworkPolicies"))]
class GetKubernetesPort: Step {

	static [string] hidden $description = @'
Specify the API port for your Kubernetes API endpoint.
'@

	static [int] hidden $minPort = 0
	static [int] hidden $maxPort = 65535

	GetKubernetesPort([Config] $config) : base(
		[GetKubernetesPort].Name, 
		$config,
		'Kubernetes API Port',
		[GetKubernetesPort]::description,
		'Enter the port number for your Kubernetes API') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		return new-object IntegerQuestion('Enter the port number for your Kubernetes port', 
            [GetKubernetesPort]::minPort,
            [GetKubernetesPort]::maxPort,
            $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.kubeApiTargetPort = ([IntegerQuestion]$question).intResponse
		return $true
	}

	[void]Reset() {
		$this.config.kubeApiTargetPort = [Config]::kubeApiTargetPortDefault
	}

	[bool]CanRun() {
		return -not $this.config.skipNetworkPolicies
	}
}

[ConfigAttribute(("namespace"))]
class Namespace : Step {

	static [string] hidden $description = @'
Specify the Kubernetes namespace where SRM components will be installed. 
For example, to install components in a namespace named 'srm', enter  
that name here.

Note: Press Enter to use the example namespace.
'@

	static [string] hidden $default = 'srm'

	Namespace([Config] $config) : base(
		[Namespace].Name, 
		$config,
		'SRM Namespace',
		[Namespace]::description,
		"Enter SRM namespace name (e.g., $([Namespace]::default))") {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		$question.emptyResponseLabel = "Accept default ($([Namespace]::default))"
		$question.validationExpr = '^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$'
		$question.validationHelp = 'The SRM namespace must consist of lowercase alphanumeric characters or ''-'', and must start and end with an alphanumeric character'
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.namespace = ([Question]$question).GetResponse([Namespace]::default)
		return $true
	}

	[void]Reset(){
		$this.config.namespace = [Namespace]::default
	}
}

[ConfigAttribute(("releaseName"))]
class ReleaseName : Step {

	static [string] hidden $description = @'
Specify the Helm release name for the SRM deployment. The name should not 
conflict with another Helm release in the Kubernetes namespace you chose.

If you plan to install multiple copies of the SRM Helm chart on a single 
cluster, specify a unique release name for each instance.

Note: Press Enter to use the example release name.
'@

	static [string] hidden $default = 'srm'

	ReleaseName([Config] $config) : base(
		[ReleaseName].Name, 
		$config,
		'SRM Helm Release Name',
		[ReleaseName]::description,
		"Enter SRM Helm release name (e.g., $([ReleaseName]::default))") {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		$question.emptyResponseLabel = "Accept default ($([ReleaseName]::default))"
		$question.validationExpr = '^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$'
		$question.validationHelp = 'The SRM release name must consist of lowercase alphanumeric characters or ''-'', and must start and end with an alphanumeric character'
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.releaseName = ([Question]$question).GetResponse([ReleaseName]::default)
		return $true
	}

	[void]Reset(){
		$this.config.releaseName = [ReleaseName]::default
	}
}

[ConfigAttribute(("skipNetworkPolicies"))]
class UseNetworkPolicyOption : Step {

	static [string] hidden $description = @'
Specify whether you want to create Network Policies, which determine 
how Kubernetes workloads can communication on your cluster. Your cluster 
must support Network Policies for the resources to apply.

Note: SRM network policies are incompatible with Istio service mesh. If
you plan to use Istio Ambient mode to establish a service mesh for mTLS
communication between SRM components, do not use SRM network policies.
'@

	UseNetworkPolicyOption([Config] $config) : base(
		[UseNetworkPolicyOption].Name, 
		$config,
		'Network Policies',
		[UseNetworkPolicyOption]::description,
		'Install Network Policies?') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, install Network Policies (requires cluster support)',
			'No, I don''t want to install Network Policies', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.skipNetworkPolicies = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.skipNetworkPolicies = $false
	}
}
