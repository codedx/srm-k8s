[ConfigAttribute(("scanFarmStorageType","skipScanFarm"))]
class ScanFarmStorage : Step {

	static [string] hidden $description = @'
Specify the type of external storage you plan to use with the Scan Farm.

You can use the following storage providers:

- Amazon S3 (https://aws.amazon.com/s3/)
- Azure Storage (https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)
- Google Cloud Storage (https://cloud.google.com/storage/docs/creating-buckets)
- S3-compatible storage (must support GetBucketLifecycleConfiguration AWS S3 API)
- MinIO (https://min.io/)
'@

	ScanFarmStorage([Config] $config) : base(
		[ScanFarmStorage].Name, 
		$config,
		'Scan Farm Storage',
		[ScanFarmStorage]::description,
		'Specify the type of Scan Farm storage you plan to use') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&AWS S3', 'Use storage provided by AWS S3'),
			[tuple]::create('&S3', 'Use storage provided by an S3-compatible provider'),
			[tuple]::create('&MinIO', 'Use storage provided by MinIO'),
			[tuple]::create('&GCS', 'Use storage provided by GCP GCS'),
			[tuple]::create('A&zure', 'Use storage provided by Azure')), -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::AwsS3 }
			1 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::MinIO }
			2 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::MinIO }
			3 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::Gcs }
			4 { $this.config.scanFarmStorageType = [ScanFarmStorageType]::Azure }
		}
		return $true
	}	

	[void]Reset(){
		$this.config.scanFarmStorageType = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmStorageBucketName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmStorageBucketName : Step {

	static [string] hidden $description = @'
The Scan Farm includes a storage service that depends on an existing
bucket in your storage system.
'@

	static [string] hidden $azureDescription = @'
The Scan Farm includes a storage service that depends on an existing
blob container in your Azure storage account.
'@

	static [string] hidden $azurePrompt = 'Enter the name of your *existing* storage service blob container'
	
	ScanFarmStorageBucketName([Config] $config) : base(
		[ScanFarmStorageBucketName].Name, 
		$config,
		'Storage Service Bucket Name',
		[ScanFarmStorageBucketName]::description,
		'Enter the name of your *existing* storage service bucket') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$prompt = $this.prompt
		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			$prompt = [ScanFarmStorageBucketName]::azurePrompt
		}
		return new-object Question($prompt)
	}

	[string]GetMessage() {

		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			return [ScanFarmStorageBucketName]::azureDescription
		}
		return $this.message
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageBucketName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageBucketName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmCacheBucketName","scanFarmStorageBucketName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmCacheBucketName : Step {

	static [string] hidden $description = @'
The Scan Farm includes a cache service that depends on an existing
bucket in your storage system.

The cache service bucket should not be geographically distributed and
it should not enable versioning, retention, or other special features.

IMPORTANT NOTE: You *must* configure your cache service bucket with
an object expiration greater than (not equal to) 7 days.
'@

	static [string] hidden $azureDescription = @'
The Scan Farm includes a cache service that depends on an existing
blob container in your Azure storage account.

The cache service container should not be geographically distributed and
it should not enable versioning, retention, or other special features.

IMPORTANT NOTE: You *must* configure your cache service blob container
with an object expiration greater than (not equal to) 7 days. You should
define the policy using the last modified date (not the creation date).
'@

	static [string] hidden $azurePrompt = 'Enter the name of your *existing* cache service blob container'

	ScanFarmCacheBucketName([Config] $config) : base(
		[ScanFarmCacheBucketName].Name, 
		$config,
		'Cache Service Bucket Name',
		[ScanFarmCacheBucketName]::description,
		'Enter the name of your *existing* cache service bucket') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$prompt = $this.prompt
		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			$prompt = [ScanFarmCacheBucketName]::azurePrompt
		}
		return new-object Question($prompt)
	}

	[string]GetMessage() {

		if ($this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure) {
			return [ScanFarmCacheBucketName]::azureDescription
		}
		return $this.message
	}

	[bool]HandleResponse([IQuestion] $question) {
		$bucketName = ([Question]$question).response
		if ($bucketName -eq $this.config.scanFarmStorageBucketName) {
			Write-Host 'You cannot use the same bucket/container for both the cache and storage services'
			return $false
		}
		$this.config.scanFarmCacheBucketName = $bucketName
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmCacheBucketName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmS3UseServiceAccountName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3AccessMethod : Step {

	static [string] hidden $description = @'
You can access your S3 buckets using either an AWS account's access and
secret key or you can configure AWS IAM Roles for Service Account (IRSA)
to grant an IAM role to a Kubernetes service account that you will use for
the Cache Service and Storage Service.

Visit the following URL for IRSA configuration details:
https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
'@

	ScanFarmS3AccessMethod([Config] $config) : base(
		[ScanFarmS3AccessMethod].Name, 
		$config,
		'AWS S3 Access Method',
		[ScanFarmS3AccessMethod]::description,
		'Do you want to use an access and secret key?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to use an access and secret key',
			'No, I want to use IRSA', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3UseServiceAccountName = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3UseServiceAccountName = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3
	}
}

[ConfigAttribute(("scanFarmS3ServiceAccountName","scanFarmS3UseServiceAccountName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3IamRoleServiceAccount : Step {

	static [string] hidden $description = @'
AWS IAM Role for Service Account (IRSA) is an alternative to using
an AWS account's access and secret key. You must configure IRSA
and create and configure the related Kubernetes service account you
will use when accessing storage buckets from the Cache Service and
Storage Service (both services require read/write access).

Visit the following URL for IRSA configuration details:
https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
'@

	ScanFarmS3IamRoleServiceAccount([Config] $config) : base(
		[ScanFarmS3IamRoleServiceAccount].Name, 
		$config,
		'AWS IRSA Role',
		[ScanFarmS3IamRoleServiceAccount]::description,
		'Enter your preconfigured service account name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3ServiceAccountName = ([Question]$question).response
		$this.config.SetNote($this.GetType().Name, "- You must configure AWS IAM Role for Service Account for your $($this.config.scanFarmS3ServiceAccountName) Kubernetes service account")
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3ServiceAccountName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3 -and
			$this.config.scanFarmS3UseServiceAccountName
	}
}

[ConfigAttribute(("scanFarmS3AccessKey","scanFarmS3UseServiceAccountName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3AccessKey : Step {

static [string] hidden $description = @'
Specify the access key required to access your S3-compliant storage
system.
'@

	ScanFarmS3AccessKey([Config] $config) : base(
		[ScanFarmS3AccessKey].Name, 
		$config,
		'S3 Access Key',
		[ScanFarmS3AccessKey]::description,
		'Enter your S3 access-key') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3AccessKey = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3AccessKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3 -and
			-not $this.config.scanFarmS3UseServiceAccountName
	}
}

[ConfigAttribute(("scanFarmS3SecretKey","scanFarmS3UseServiceAccountName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3SecretKey : Step {

static [string] hidden $description = @'
Specify the secret key required to access your S3-compliant storage
system.
'@

	ScanFarmS3SecretKey([Config] $config) : base(
		[ScanFarmS3SecretKey].Name, 
		$config,
		'S3 Secret Key',
		[ScanFarmS3SecretKey]::description,
		'Enter your S3 secret-key') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3SecretKey = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3SecretKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3 -and
			-not $this.config.scanFarmS3UseServiceAccountName
	}
}

[ConfigAttribute(("scanFarmS3Region","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3Region : Step {

	static [string] hidden $description = @'
Specify the region where your S3-compliant storage bucket resides.
'@

	ScanFarmS3Region([Config] $config) : base(
		[ScanFarmS3Region].Name, 
		$config,
		'S3 Region',
		[ScanFarmS3Region]::description,
		'Enter your S3 region') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmS3Region = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmS3Region = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::AwsS3
	}
}

[ConfigAttribute(("scanFarmGcsProjectName","scanFarmStorageType","skipScanFarm"))]
class ScanFarmGcsProjectName : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a GCP project when using GCS storage.
'@
	
	ScanFarmGcsProjectName([Config] $config) : base(
		[ScanFarmGcsProjectName].Name, 
		$config,
		'Scan Farm GCP Project',
		[ScanFarmGcsProjectName]::description,
		'Enter your GCP project name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmGcsProjectName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmGcsProjectName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Gcs
	}
}

[ConfigAttribute(("scanFarmGcsSvcAccountKey","scanFarmStorageType","skipScanFarm"))]
class ScanFarmGcsKey : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a GCP service account key when using GCS storage.

The service account must have read/write access to the scan farm storage 
and cache buckets.

Visit the following URL for information on obtaining your JSON service
account key: https://cloud.google.com/iam/docs/keys-create-delete
'@
	
	ScanFarmGcsKey([Config] $config) : base(
		[ScanFarmGcsKey].Name, 
		$config,
		'Scan Farm GCP Key',
		[ScanFarmGcsKey]::description,
		'Enter your GCP service account key JSON file path') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt, $false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmGcsSvcAccountKey = ([PathQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmGcsSvcAccountKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Gcs
	}
}

[ConfigAttribute(("scanFarmAzureSubscriptionId","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureSubscription : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure subscription when using Azure storage.

You can find your Azure subscription ID with this command:
az account show
'@
	
	ScanFarmAzureSubscription([Config] $config) : base(
		[ScanFarmAzureSubscription].Name, 
		$config,
		'Scan Farm Azure Subscription',
		[ScanFarmAzureSubscription]::description,
		'Enter your Azure subscription ID') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureSubscriptionId = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureSubscriptionId = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureTenantId","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureTenantId : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure tenant when using Azure storage.

You can find your Azure tenant ID with this command:
az account show
'@
	
	ScanFarmAzureTenantId([Config] $config) : base(
		[ScanFarmAzureTenantId].Name, 
		$config,
		'Scan Farm Azure Tenant',
		[ScanFarmAzureTenantId]::description,
		'Enter your Azure tenant ID') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureTenantId = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureTenantId = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureResourceGroup","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureResourceGroup : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure Resource Group containing a storage
account when using Azure storage.

You must provide the Azure Resource Group name that contains your
Azure storage account.
'@
	
	ScanFarmAzureResourceGroup([Config] $config) : base(
		[ScanFarmAzureResourceGroup].Name, 
		$config,
		'Scan Farm Azure Resource Group',
		[ScanFarmAzureResourceGroup]::description,
		'Enter the name of your Azure resource group') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureResourceGroup = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureResourceGroup = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureStorageAccount","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureStorageAccountName : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure storage account when using Azure storage.
'@
	
	ScanFarmAzureStorageAccountName([Config] $config) : base(
		[ScanFarmAzureStorageAccountName].Name, 
		$config,
		'Scan Farm Azure Storage Account',
		[ScanFarmAzureStorageAccountName]::description,
		'Enter the name of your Azure storage account') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureStorageAccount = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureStorageAccount = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureStorageAccountKey","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureStorageAccountKey : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure storage account key when using Azure storage.

You can find your access key on the Azure Portal "Access keys" tab for your 
storage account.
'@
	
	ScanFarmAzureStorageAccountKey([Config] $config) : base(
		[ScanFarmAzureStorageAccountKey].Name, 
		$config,
		'Scan Farm Azure Storage Account Key',
		[ScanFarmAzureStorageAccountKey]::description,
		'Enter the name of your Azure storage account key') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureStorageAccountKey = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureStorageAccountKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureEndpoint","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureEndpoint : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure endpoint when using Azure storage.

You can find your blob service Azure endpoint on the Azure Portal 
"Endpoints" tab for your storage account.

It will typically look like this:
https://<storage-account-name>.blob.core.windows.net
'@
	
	ScanFarmAzureEndpoint([Config] $config) : base(
		[ScanFarmAzureEndpoint].Name, 
		$config,
		'Scan Farm Azure Endpoint',
		[ScanFarmAzureEndpoint]::description,
		'Enter your Azure endpoint URL') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureEndpoint = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureEndpoint = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureClientId","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureClientId : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure service account with access to your
Azure storage container.

You must provide the client identifier for your application registered 
in Microsoft Entra ID with access to your storage account. A client ID
typically looks like this: 9b1f8b8d-db8f-4683-8023-2dd7962b1e96
'@
	
	ScanFarmAzureClientId([Config] $config) : base(
		[ScanFarmAzureClientId].Name, 
		$config,
		'Scan Farm Azure Client ID',
		[ScanFarmAzureClientId]::description,
		'Enter your Azure account client ID') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureClientId = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureClientId = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmAzureClientSecret","scanFarmStorageType","skipScanFarm"))]
class ScanFarmAzureClientSecret : Step {

	static [string] hidden $description = @'
The Scan Farm depends on an Azure service account with access to your
Azure storage container.

You must provide the client secret for your application registered 
in Microsoft Entra ID with access to your storage account.
'@
	
	ScanFarmAzureClientSecret([Config] $config) : base(
		[ScanFarmAzureClientSecret].Name, 
		$config,
		'Scan Farm Azure Client Secret',
		[ScanFarmAzureClientSecret]::description,
		'Enter your Azure account client secret') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmAzureClientSecret = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmAzureClientSecret = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::Azure
	}
}

[ConfigAttribute(("scanFarmMinIOHostname","scanFarmStorageType","skipScanFarm"))]
class ScanFarmObjectStorageHostname : Step {

	static [string] hidden $description = @'
The Scan Farm depends on external object storage and can use any storage
that is fully compatible with the AWS S3 API.

Note: Do not enter a URL or port here; specify the storage hostname only.
'@

	ScanFarmObjectStorageHostname([Config] $config) : base(
		[ScanFarmObjectStorageHostname].Name, 
		$config,
		'Scan Farm Object Storage Hostname',
		[ScanFarmObjectStorageHostname]::description,
		'Enter your storage hostname') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIOHostname = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIOHostname = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmMinIOPort","scanFarmStorageType","skipScanFarm"))]
class ScanFarmObjectStoragePort : Step {

	static [string] hidden $description = @'
The Scan Farm depends on external object storage and can use any storage
that is fully compatible with the AWS S3 API.

Note: If you are using MinIO, its default port is 9000.
'@

	ScanFarmObjectStoragePort([Config] $config) : base(
		[ScanFarmObjectStoragePort].Name, 
		$config,
		'Scan Farm Object Storage Port',
		[ScanFarmObjectStoragePort]::description,
		'Enter your storage port') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object IntegerQuestion($prompt, 0, 65535, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIOPort = ([IntegerQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIOPort = ''
	}
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmStorageIsProxied","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3StorageProxy : Step {

	static [string] hidden $description = @'
If your object storage (e.g., MinIO) is running on the same cluster, you
can proxy your storage by using the same hostname for both SRM and your
object storage. For example, if your SRM hostname is srm.local, you can
make your object storage available at https://srm.local/upload/.

If your object storage is running external to your cluster (e.g., your
SRM hostname is srm.local and your storage is available at a different
URL like https://storage.local:9000/), then you cannot proxy access to
your storage.

'@

	ScanFarmS3StorageProxy([Config] $config) : base(
		[ScanFarmS3StorageProxy].Name, 
		$config,
		'Scan Farm Object Storage Proxy',
		[ScanFarmS3StorageProxy]::description,
		'Do you plan to proxy your storage using your SRM hostname?') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I want to proxy my storage using my SRM hostname', 
			'No, my storage will use a separate URL', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageIsProxied = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageIsProxied = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmStorageContextPath","scanFarmStorageIsProxied","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3StorageContextPath : Step {

	static [string] hidden $description = @'
Making your object storage available with your SRM hostname requires a
proxy/context path.

For example, if your SRM hostname is srm.local, making your object storage
available at https://srm.local/upload/ would mean specifying "upload" for
your context path.

Note: You can find an example NGINX Community ingress resource at this URL:
https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md#bitnami-minio-chart-pre-work

'@

	ScanFarmS3StorageContextPath([Config] $config) : base(
		[ScanFarmS3StorageContextPath].Name, 
		$config,
		'Scan Farm Proxy Context Path',
		[ScanFarmS3StorageContextPath]::description,
		'Enter your proxy context path') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageContextPath = $question.response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageContextPath = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO -and
			$this.config.scanFarmStorageIsProxied
	}
}

[ConfigAttribute(("scanFarmStorageExternalUrl","scanFarmStorageIsProxied","scanFarmStorageType","skipScanFarm"))]
class ScanFarmS3StorageExternalURL : Step {

	static [string] hidden $description = @'
Your external storage URL is the URL that you can use to access object
storage from outside your cluster. You should enter your URL, port, and
any context path that's required. 

For example, if your storage instance uses hostname my-minio with HTTPS, 
port 9000, and no context path, enter https://my-minio:9000. If your
storage instance uses an "upload" context path, include the context path
by specifying https://my-minio:9000/upload/.

'@

	ScanFarmS3StorageExternalURL([Config] $config) : base(
		[ScanFarmS3StorageExternalURL].Name, 
		$config,
		'Scan Farm Object Storage External URL',
		[ScanFarmS3StorageExternalURL]::description,
		'Enter your external storage URL') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageExternalUrl = $question.response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageExternalUrl = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO -and
			-not $this.config.scanFarmStorageIsProxied
	}
}

[ConfigAttribute(("scanFarmMinIORootUsername","scanFarmStorageType","skipScanFarm"))]
class ScanFarmObjectStorageAccessKey : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a user access key with access to your storage
bucket. If using MinIO, you can provide a MinIO username with read/write
access and access to cache bucket lifecycle rules.
'@

	ScanFarmObjectStorageAccessKey([Config] $config) : base(
		[ScanFarmObjectStorageAccessKey].Name, 
		$config,
		'Scan Farm Object Storage Access Key',
		[ScanFarmObjectStorageAccessKey]::description,
		'Enter your storage access key') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIORootUsername = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIORootUsername = ''
	}
	
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmMinIORootPwd","scanFarmStorageType","skipScanFarm"))]
class ScanFarmObjectStorageSecretKey : Step {

	static [string] hidden $description = @'
The Scan Farm depends on a user secret key with access to your storage
bucket. If using MinIO, you can provide a MinIO username with read/write
access and access to cache bucket lifecycle rules.
'@

	ScanFarmObjectStorageSecretKey([Config] $config) : base(
		[ScanFarmObjectStorageSecretKey].Name, 
		$config,
		'Scan Farm Object Storage Secret Key',
		[ScanFarmObjectStorageSecretKey]::description,
		'Enter your storage secret key') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIORootPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIORootPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmStorageHasInClusterUrl","scanFarmStorageType","skipScanFarm"))]
class ScanFarmInClusterStorage : Step {

	static [string] hidden $description = @'
If your Scan Farm storage runs on the same cluster where you plan to
install SRM, the SRM web component can access your storage using the
in-cluster storage URL. This is an optional optimization that works
only when SRM and your storage service runs on the same cluster.
'@

	ScanFarmInClusterStorage([Config] $config) : base(
		[ScanFarmInClusterStorage].Name, 
		$config,
		'Scan Farm In-Cluster Storage',
		[ScanFarmInClusterStorage]::description,
		'Do you want to specify an in-cluster storage URL?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'For internal operations, SRM Web should use an in-cluster URL',
			'No, SRM Web should use an in-cluster URL', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$choice = ([YesNoQuestion]$question).choice
		$this.config.scanFarmStorageHasInClusterUrl = $choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageHasInClusterUrl = $false
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmStorageHasInClusterUrl","scanFarmStorageInClusterUrl","scanFarmStorageType","skipScanFarm"))]
class ScanFarmInClusterStorageUrl : Step {

	static [string] hidden $description = @'
The SRM web component will use the URL you specify here to access your
storage service.

If your storage service is deployed to the same namespace as SRM, you
can specify a non-fully qualified URL like this: http://minio:9000

If your storage service is deployed to another namespace, you should
specify a fully qualified URL that will resolve from SRM's namespace.
'@
	
	ScanFarmInClusterStorageUrl([Config] $config) : base(
		[ScanFarmInClusterStorageUrl].Name, 
		$config,
		'Scan Farm In-Cluster Storage Url',
		[ScanFarmInClusterStorageUrl]::description,
		'Enter the in-cluster URL for your storage service') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageInClusterUrl = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageInClusterUrl = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO -and
			$this.config.scanFarmStorageHasInClusterUrl
	}
}


[ConfigAttribute(("scanFarmMinIOSecure","scanFarmMinIOVerifyHostname","scanFarmStorageType","skipScanFarm"))]
class ScanFarmObjectStorageTLS : Step {

	static [string] hidden $description = @'
Specify whether you want to enable TLS to protect the communications 
between the Scan Farm and your external object storage.

Note: To enable TLS, you must have access to the certificate associated
with your object storage's CA.
'@

	ScanFarmObjectStorageTLS([Config] $config) : base(
		[ScanFarmObjectStorageTLS].Name, 
		$config,
		'Scan Farm Object Storage TLS',
		[ScanFarmObjectStorageTLS]::description,
		'Specify the SSL/TLS mode for your storage connection') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Disable', 'Do not use TLS'),
			[tuple]::create('&Secure', 'Use TLS w/o hostname verification'),
			[tuple]::create('Secure + &Hostname Verification', 'Use TLS w/ hostname verification')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$choice = ([MultipleChoiceQuestion]$question).choice
		$this.config.scanFarmMinIOSecure = $choice -eq 1 -or $choice -eq 2
		$this.config.scanFarmMinIOVerifyHostname = $choice -eq 2
		return $true
	}	

	[void]Reset(){
		$this.config.scanFarmMinIOSecure = $false
		$this.config.scanFarmMinIOVerifyHostname = $false
	}
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO
	}
}

[ConfigAttribute(("scanFarmMinIOSecure","scanFarmMinIOServerCert","scanFarmStorageType","skipScanFarm"))]
class ScanFarmObjectStorageCert : Step {

	static [string] hidden $description = @'
Specify a file path to the CA file for your object storage host.
'@

	ScanFarmObjectStorageCert([Config] $config) : base(
		[ScanFarmObjectStorageCert].Name, 
		$config,
		'Scan Farm Object Storage Cert',
		[ScanFarmObjectStorageCert]::description,
		'Enter the path to the certificate of your storage CA') {}
	
	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmMinIOServerCert = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmMinIOServerCert = ''
	}
	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and 
			$this.config.scanFarmStorageType -eq [ScanFarmStorageType]::MinIO -and
			$this.config.scanFarmMinIOSecure
	}
}

