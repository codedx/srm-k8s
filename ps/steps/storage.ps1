[ConfigAttribute(("skipMinIO","skipToolOrchestration","workflowStorageType"))]
class UseExternalStorage : Step {

	static [string] hidden $description = @'
SRM orchestrated analyses depend on an object storage system. You 
can use any storage system that supports an AWS S3-compliant API (e.g., 
AWS, GCP, MinIO, etc.). Alternatively, the SRM deployment includes 
an older MinIO version that you can use.
'@

	UseExternalStorage([Config] $config) : base(
		[UseExternalStorage].Name, 
		$config,
		'Orchestrated Analysis Storage',
		[UseExternalStorage]::description,
		'What object storage configuration will you use?') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('On-Cluster &MinIO', 'Use an on-cluster MinIO instance'),
			[tuple]::create('&External (Access Key)', 'Use external workflow storage with access key'),
			[tuple]::create('External (&AWS IAM)', 'Use external workflow storage with AWS IAM')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.skipMinIO = $true;

		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.workflowStorageType = [WorkflowStorageType]::OnCluster; $this.config.skipMinIO = $false; }
			1 { $this.config.workflowStorageType = [WorkflowStorageType]::AccessKey }
			2 { $this.config.workflowStorageType = [WorkflowStorageType]::AwsIAM }
		}
		return $true
	}

	[void]Reset(){
		$this.config.skipMinIO = $false
		$this.config.workflowStorageType = [WorkflowStorageType]::OnCluster
	}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration
	}
}

[ConfigAttribute(("externalWorkflowStorageEndpoint","skipMinIO"))]
class ExternalStorageEndpoint : Step {

	static [string] hidden $description = @'
Specify the endpoint for your object storage system. Your endpoint should
include a hostname and an optional port.

An AWS S3 endpoint might look like 's3-us-east-2.amazonaws.com' and a MinIO
endpoint might look like 'my-minio-hostname:9000'.
'@

	ExternalStorageEndpoint([Config] $config) : base(
		[ExternalStorageEndpoint].Name, 
		$config,
		'Orchestrated Analysis Storage Endpoint',
		[ExternalStorageEndpoint]::description,
		'Enter your external object storage endpoint') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStorageEndpoint = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalWorkflowStorageEndpoint = ''
	}

	[bool]CanRun() {
		return $this.config.skipMinIO
	}
}

[ConfigAttribute(("externalWorkflowStorageEndpointSecure","skipMinIO"))]
class ExternalStorageTLS : Step {

	static [string] hidden $description = @'
Specify whether your object storage system is accessible via a secure 
connection protected by TLS.
'@

	ExternalStorageTLS([Config] $config) : base(
		[ExternalStorageTLS].Name, 
		$config,
		'Orchestrated Analysis Storage Endpoint Security',
		[ExternalStorageTLS]::description,
		'Is your object storage system connection secure?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, my object storage system connection is secure (i.e., uses TLS)', 
			'No, my object storage system is not secure', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStorageEndpointSecure = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.externalWorkflowStorageEndpointSecure = $false
	}

	[bool]CanRun() {
		return $this.config.skipMinIO
	}
}

[ConfigAttribute(("externalWorkflowStorageUsername","workflowStorageType"))]
class ExternalStorageUsername : Step {

	static [string] hidden $description = @'
Specify the username of the account that will connect to your object 
storage system. The account must have read/write permissions to a
storage bucket you will specify later. If the bucket does not exist,
the account should have permission to create that bucket.
'@

	ExternalStorageUsername([Config] $config) : base(
		[ExternalStorageUsername].Name, 
		$config,
		'Orchestrated Analysis Storage Username',
		[ExternalStorageUsername]::description,
		'Enter your external object storage username') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStorageUsername = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalWorkflowStorageUsername = ''
	}

	[bool]CanRun() {
		return $this.config.workflowStorageType -eq [WorkflowStorageType]::AccessKey
	}
}

[ConfigAttribute(("externalWorkflowStoragePwd","workflowStorageType"))]
class ExternalStoragePassword : Step {

	static [string] hidden $description = @'
Specify the password of the account that will connect to your object 
storage system. The account must have read/write permissions to a
storage bucket you will specify later. If the bucket does not exist,
the account should have permission to create that bucket.
'@

	ExternalStoragePassword([Config] $config) : base(
		[ExternalStoragePassword].Name, 
		$config,
		'Orchestrated Analysis Storage Password',
		[ExternalStoragePassword]::description,
		'Enter your external object storage password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStoragePwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalWorkflowStoragePwd = ''
	}

	[bool]CanRun() {
		return $this.config.workflowStorageType -eq [WorkflowStorageType]::AccessKey
	}
}

[ConfigAttribute(("externalWorkflowStorageBucketName","skipMinIO"))]
class ExternalStorageBucket : Step {

	static [string] hidden $description = @'
Specify the name of the object storage bucket where SRM will store
orchestrated analysis data. If this bucket does not exist, SRM
will attempt to create the bucket using the object storage system
credential you specified.
'@

	ExternalStorageBucket([Config] $config) : base(
		[ExternalStorageBucket].Name, 
		$config,
		'Orchestrated Analysis Storage Bucket',
		[ExternalStorageBucket]::description,
		'Enter the name of your object storage bucket') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStorageBucketName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalWorkflowStorageBucketName = ''
	}

	[bool]CanRun() {
		return $this.config.skipMinIO
	}
}

[ConfigAttribute(("externalWorkflowStorageEndpointSecure","externalWorkflowStorageTrustCert","skipMinIO"))]
class ExternalStorageTrustCert : Step {

	static [string] hidden $description = @'
Specify whether your object storage system endpoint uses a certificate
not issued by a well-known certificate authority. If so, you will need
to specify a file that includes the endpoint's certificate chain.
'@

	ExternalStorageTrustCert([Config] $config) : base(
		[ExternalStorageTrustCert].Name, 
		$config,
		'Orchestrated Analysis Storage Trust',
		[ExternalStorageTrustCert]::description,
		'Do you need to provide your endpoint''s certificate chain?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, my object storage system uses a certificate not issued by a well-known CA', 
			'No, my object storage system uses a certificate issued by a well-known CA', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStorageTrustCert = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.externalWorkflowStorageTrustCert = $false
	}

	[bool]CanRun() {
		return $this.config.skipMinIO -and $this.config.externalWorkflowStorageEndpointSecure 
	}
}

[ConfigAttribute(("externalWorkflowStorageCertChainPath","externalWorkflowStorageTrustCert","skipMinIO"))]
class ExternalStorageCertificate : Step {

	static [string] hidden $description = @'
Specify a path to the certificate file for your object storage system endpoint.
The file should include the entire certificate chain.
'@

	ExternalStorageCertificate([Config] $config) : base(
		[ExternalStorageCertificate].Name,
		$config,
		'Orchestrated Analysis Storage Certificate',
		[ExternalStorageCertificate]::description,
		'Enter a certificate path') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalWorkflowStorageCertChainPath = ([Question]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.skipMinIO -and $this.config.externalWorkflowStorageTrustCert 
	}

	[void]Reset(){
		$this.config.externalWorkflowStorageCertChainPath = ''
	}
}

[ConfigAttribute(("serviceAccountToolService","workflowStorageType"))]
class ServiceAccountNameToolService : Step {

	static [string] hidden $description = @'
Specify the Tool Service Kubernetes service account name that you linked
to an IAM role/policy with the required object storage permissions.

You can find the Tool Service AWS object storage permissions at the following URL:
https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md#aws-irsa
'@

	ServiceAccountNameToolService([Config] $config) : base(
		[ServiceAccountNameToolService].Name,
		$config,
		'Tool Service Account',
		[ServiceAccountNameToolService]::description,
		'Enter your Tool Service Kubernetes Service Account name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.serviceAccountToolService = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.serviceAccountToolService = ''
	}

	[bool]CanRun() {
		return $this.config.workflowStorageType -eq [WorkflowStorageType]::AwsIAM
	}
}

[ConfigAttribute(("serviceAccountWorkflow","workflowStorageType"))]
class ServiceAccountNameWorkflow : Step {

	static [string] hidden $description = @'
Specify the tool workflow Kubernetes service account name that you linked
to an IAM role/policy with the required object storage permissions.

You can find the tool workflow AWS object storage permissions at the following URL:
https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md#aws-irsa
'@

	ServiceAccountNameWorkflow([Config] $config) : base(
		[ServiceAccountNameWorkflow].Name,
		$config,
		'Workflow Service Account',
		[ServiceAccountNameWorkflow]::description,
		'Enter your Workflow Kubernetes Service Account name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.serviceAccountWorkflow = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.serviceAccountWorkflow = ''
	}

	[bool]CanRun() {
		return $this.config.workflowStorageType -eq [WorkflowStorageType]::AwsIAM
	}
}
