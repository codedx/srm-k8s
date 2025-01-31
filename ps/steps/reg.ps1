[ConfigAttribute(("skipScanFarm","useDockerRedirection"))]
class UseDockerRegistry : Step {

	static [string] hidden $description = @'
Specify whether you want to use your own Docker registry. You will need 
to add the SRM Docker images you plan to use to your registry.

Enter No if you plan to load SRM Docker images from their default location
on Docker Hub.
'@

	UseDockerRegistry([Config] $config) : base(
		[UseDockerRegistry].Name, 
		$config,
		'Docker Registry',
		[UseDockerRegistry]::description,
		'Do you want to use your own Docker registry?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes - I want to use my own Docker registry', 
			'No - I do not want to use a different Docker registry', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useDockerRedirection = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.useDockerRedirection = $false
	}

	[bool]CanRun(){
		return $this.config.skipScanFarm
	}
}

[ConfigAttribute(("dockerRegistry","skipScanFarm","useDockerRedirection"))]
class DockerRegistryHost  : Step {

	static [string] hidden $description = @'
Specify the hostname for your Docker registry. These are examples of
private Docker registry hosts:

  - gcr.io (GCP Container Registry)
  - us-central1-docker.pkg.dev (GCP Artifact Registry)
  - name-placeholder.azurecr.io (Azure Container Registry)
  - id-placeholder.dkr.ecr.us-east-2.amazonaws.com (AWS Elastic Container Registry)
'@

	static [string] hidden $pullPushInstructionLink = 'https://github.com/codedx/srm-k8s/blob/main/docs/deploy/registry.md'

	static [string] hidden $notes = "- Follow instructions at $([DockerRegistryHost]::pullPushInstructionLink) to pull/push Black Duck Docker images to your private registry."

	static [string] hidden $scanFarmDescription = @"
Your SRM configuration requires you to pull SRM Docker images from the
Black Duck private Docker registry and push them to your own private 
registry. You can use a private registry hosted by a cloud provider 
(e.g., AWS, GCP, Azure, etc.) or deploy your own.

Visit the following links for Docker image pull/tag/push instructions:
$([DockerRegistryHost]::pullPushInstructionLink)

"@

	DockerRegistryHost([Config] $config) : base(
		[DockerRegistryHost].Name, 
		$config,
		'Docker Registry',
		[DockerRegistryHost]::description,
		'Enter your private Docker registry host') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.blacklist = @("/")
		return $question
	}

	[string]GetMessage() {

		if (-not $this.config.skipScanFarm) {
			return "$([DockerRegistryHost]::scanFarmDescription)`n$($this.message)"
		}
		return $this.message
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.dockerRegistry = ([Question]$question).response
		if (-not $this.config.skipScanFarm) {
			$this.config.SetNote($this.GetType().Name, [DockerRegistryHost]::notes)
		}
		return $true
	}

	[void]Reset(){
		$this.config.dockerRegistry = ''
		$this.config.RemoveNote($this.GetType().Name)
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -or $this.config.useDockerRedirection
	}
}

[ConfigAttribute(("skipDockerRegistryCredential","skipScanFarm","useDockerRedirection"))]
class UseDockerRegistryCredential : Step {

	static [string] hidden $description = @'
Specify whether your Docker registry requires a credential to access. 
If you are using a Docker registry that supports anonymous access (docker.io) 
or one that is private but does not require a credential (e.g., an ECR accessed 
from an EKS cluster, a GCR accessed from a GKE cluster, etc.), answer No.
'@

    UseDockerRegistryCredential([Config] $config) : base(
		[UseDockerRegistryCredential].Name, 
		$config,
		'Docker Registry Credential',
		[UseDockerRegistryCredential]::description,
		'Do you want to specify a Docker registry credential?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes - My Docker registry requires a username and password', 
			'No - My Docker registry does not require a credential', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.skipDockerRegistryCredential = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.skipDockerRegistryCredential = $true
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -or $this.config.useDockerRedirection
	}
}

[ConfigAttribute(("dockerImagePullSecretName","skipDockerRegistryCredential","skipScanFarm","useDockerRedirection"))]
class DockerImagePullSecret : Step {

	static [string] hidden $description = @'
Specify the name of the Docker Image Pull Secret that the setup script will 
create to store your private Docker registry credential.
'@

	DockerImagePullSecret([Config] $config) : base(
		[DockerImagePullSecret].Name, 
		$config,
		'Docker Image Pull Secret',
		[DockerImagePullSecret]::description,
		'Enter a name for your Docker Image Pull Secret') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.dockerImagePullSecretName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.dockerImagePullSecretName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -or $this.config.useDockerRedirection -and -not $this.config.skipDockerRegistryCredential
	}
}

[ConfigAttribute(("dockerRegistryUser","skipDockerRegistryCredential","skipScanFarm","useDockerRedirection"))]
class DockerRegistryUser  : Step {

	static [string] hidden $description = @'
Specify the username of a user with pull access to your private registry.
'@

	DockerRegistryUser([Config] $config) : base(
		[DockerRegistryUser].Name, 
		$config,
		'Docker Registry Username',
		[DockerRegistryUser]::description,
		'Enter your private Docker registry username') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.dockerRegistryUser = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.dockerRegistryUser = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -or $this.config.useDockerRedirection -and -not $this.config.skipDockerRegistryCredential
	}
}

[ConfigAttribute(("dockerRegistryPwd","dockerRegistryUser","skipDockerRegistryCredential","skipScanFarm","useDockerRedirection"))]
class DockerRegistryPwd  : Step {

	DockerRegistryPwd([Config] $config) : base(
		[DockerRegistryPwd].Name, 
		$config,
		'Docker Registry Password',
		'',
		'Enter your private Docker registry password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.dockerRegistryPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[string]GetMessage() {
		return "Specify the password for the $($this.config.dockerRegistryUser) account."
	}

	[void]Reset(){
		$this.config.dockerRegistryPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -or $this.config.useDockerRedirection -and -not $this.config.skipDockerRegistryCredential
	}
}
