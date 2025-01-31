[ConfigAttribute(("skipScanFarm","useDockerRedirection","useDockerRepositoryPrefix"))]
class UseDockerRepositoryPrefix : Step {

	static [string] hidden $description = @'
By default, SRM will load Docker images from the root of a Docker
registry. If your copies of SRM Docker images reside below the
root level, you will need to specify a Docker repository prefix.

For example, you do not need a prefix if your Docker repository is 
id.dkr.ecr.us-east-2.amazonaws.com and the SRM Tomcat Docker image 
can be found at id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat.

However, if your SRM Tomcat Docker image is located under "my-srm" (as in
id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat), you
should specify this prefix: 

my-srm

Note: If you are using a GCP Container Registry, answer Yes.
'@

	UseDockerRepositoryPrefix([Config] $config) : base(
		[UseDockerRepositoryPrefix].Name, 
		$config,
		'SRM Docker Repository Prefix',
		[UseDockerRepositoryPrefix]::description,
		'Do you need to specify a repository prefix?') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		return new-object YesNoQuestion($prompt,
			'I need to specify a repository prefix',
			'I do not need to specify a repository prefix', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$choice = ([YesNoQuestion]$question).choice
		$this.config.useDockerRepositoryPrefix = $choice -eq 0

		return $true
	}

	[void]Reset(){
		$this.config.useDockerRepositoryPrefix = $false
	}

	[bool]CanRun(){
		return -not $this.config.skipScanFarm -or $this.config.useDockerRedirection
	}
}

[ConfigAttribute(("dockerRepositoryPrefix","useDockerRepositoryPrefix"))]
class DockerRepositoryPrefix : Step {

	static [string] hidden $description = @'
Specify a repository prefix for SRM Docker image references when
pulling Docker images from an alternate registry.

For example, if you are pulling SRM Docker images from an ECR with a
repository name that includes my-srm, specify the following:

my-srm

The above will have your SRM Tomcat Docker image reference resolve to:
id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:version
'@

	DockerRepositoryPrefix([Config] $config) : base(
		[DockerRepositoryPrefix].Name, 
		$config,
		'Docker Repository Prefix',
		[DockerRepositoryPrefix]::description,
		'Enter your SRM Docker repository prefix') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.dockerRepositoryPrefix = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.dockerRepositoryPrefix = ''
	}

	[bool]CanRun() {
		return $this.config.useDockerRepositoryPrefix
	}
}

[ConfigAttribute(("useDefaultDockerImages"))]
class UseDefaultDockerImages : Step {

	static [string] hidden $description = @'
Specify whether you want to use the default versions of SRM Docker images. 
You can specify one or more alternative versions for required Docker 
images.
'@

	UseDefaultDockerImages([Config] $config) : base(
		[UseDefaultDockerImages].Name, 
		$config,
		'SRM Docker Images',
		[UseDefaultDockerImages]::description,
		'Do you want to specify alternate Docker image versions?') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		return new-object YesNoQuestion($prompt,
			'I want to specify Docker image versions',
			'I do not want to specify Docker image versions',1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$choice = ([YesNoQuestion]$question).choice
		$this.config.useDefaultDockerImages = $choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.useDefaultDockerImages = $true
	}
}

class DockerImageVersionStep : Step {

	static [string] hidden $description = @'
You can use the default Docker image version by pressing Enter and accepting 
the default value, or you can specify a specific Docker image version.
'@

	[string] $titleDetails
	
	DockerImageVersionStep([string] $name,
		[Config] $config, 
		[string] $title,
		[string] $titleDetails,
		[string] $prompt) : base(
			$name, 
			$config,
			$title,
			'',
			$prompt) {
		$this.titleDetails = $titleDetails
	}

	[IQuestion]MakeQuestion([string] $prompt) {

		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		return $question
	}

	[string]GetMessage() {
		return [DockerImageVersionStep]::description + "`n`n" + $this.titleDetails
	}
}

[ConfigAttribute(("imageVersionWeb","useDefaultDockerImages"))]
class WebDockerImageVersion : DockerImageVersionStep {

	WebDockerImageVersion([Config] $config) : base(
		[WebDockerImageVersion].Name, 
		$config,
		'SRM Web Docker Image',
		'The SRM Tomcat Docker image packages the main SRM web application.',
		'Enter the SRM Tomcat Docker image version') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.imageVersionWeb = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.imageVersionWeb = ''
	}

	[bool]CanRun() {
		return -not $this.config.useDefaultDockerImages
	}
}

[ConfigAttribute(("imageVersionMariaDB","skipDatabase","useDefaultDockerImages"))]
class MariaDBDockerImageVersion : DockerImageVersionStep {

	MariaDBDockerImageVersion([Config] $config) : base(
		[MariaDBDockerImageVersion].Name, 
		$config,
		'SRM MariaDB Docker Image',
		'The SRM MariaDB Docker image is used to host the SRM database.',
		'Enter the SRM MariaDB Docker image version') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.imageVersionMariaDB = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.imageVersionMariaDB = ''
	}

	[bool]CanRun() {
		return -not $this.config.useDefaultDockerImages -and -not $this.config.skipDatabase
	}
}

[ConfigAttribute(("imageVersionTo","skipToolOrchestration","useDefaultDockerImages"))]
class ToolOrchestrationDockerImageVersion : DockerImageVersionStep {

	ToolOrchestrationDockerImageVersion([Config] $config) : base(
		[ToolOrchestrationDockerImageVersion].Name, 
		$config,
		'SRM Tool Orchestration Docker Image',
		'The SRM Tool Orchestration Docker images support the optional orchestration feature.',
		'Enter the SRM Tools Docker image version') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.imageVersionTo = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.imageVersionTo = ''
	}

	[bool]CanRun() {
		return -not $this.config.useDefaultDockerImages -and -not $this.config.skipToolOrchestration
	}
}

[ConfigAttribute(("imageVersionMinio","skipMinIO","skipToolOrchestration","useDefaultDockerImages"))]
class MinioDockerImageVersion : DockerImageVersionStep {

	MinioDockerImageVersion([Config] $config) : base(
		[MinioDockerImageVersion].Name, 
		$config,
		'MinIO Docker Image',
		'The MinIO Docker image provides workflow storage for Tool Orchestration.',
		'Enter the MinIO Docker image version') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.imageVersionMinio = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.imageVersionMinio = ''
	}

	[bool]CanRun() {
		return -not $this.config.useDefaultDockerImages -and -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO
	}
}

[ConfigAttribute(("imageVersionWorkflow","skipToolOrchestration","useDefaultDockerImages"))]
class WorkflowDockerImageVersion : DockerImageVersionStep {

	WorkflowDockerImageVersion([Config] $config) : base(
		[WorkflowDockerImageVersion].Name, 
		$config,
		'SRM Workflow Docker Image',
		'The SRM Workflow Docker image is the Argo workflow version for Tool Orchestration.',
		'Enter the SRM Workflow Controller Docker image version') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.imageVersionWorkflow = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.imageVersionWorkflow = ''
	}

	[bool]CanRun() {
		return -not $this.config.useDefaultDockerImages -and -not $this.config.skipToolOrchestration
	}
}
