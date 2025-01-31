[ConfigAttribute(("skipScanFarm"))]
class UseScanFarm : Step {

	static [string] hidden $description = @'
SRM includes a scan farm feature, a separately licensed component 
capable of running SAST and SCA scans.

The scan farm depends on the following external systems that you
must separately provision/configure:

1) PostgreSQL
2) Redis
3) Object Storage (e.g., AWS, GCS, Azure, MinIO)
'@

	static [string] hidden $notes = @'
- Your deployment includes the scan farm feature. Remember to complete the following tasks:
  * Configure external dependencies (PostgreSQL, Redis, Object Storage)
  * Define your "small" scan job node pool:
  *   Assign a pool-type label (pool-type=small) to analysis node(s).
  *   Assign a scanner node taint (NodeType=ScannerNode:NoSchedule) to analysis node(s).
  *   NOTE: A "small" pool-type requires one or more nodes with 6.5 vCPUs and 26 GB of memory
'@

	UseScanFarm([Config] $config) : base(
		[UseScanFarm].Name, 
		$config,
		'Scan Farm',
		[UseScanFarm]::description,
		'Install Scan Farm Components?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I have an SRM license that includes SAST/SCA scanning', 
			'No, I don''t want to use the Scan Farm at this time', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$this.config.skipScanFarm = ([YesNoQuestion]$question).choice -eq 1

		if (-not $this.config.skipScanFarm) {
			$this.config.SetNote($this.GetType().Name, [UseScanFarm]::notes)
		}
		return $true
	}

	[void]Reset(){
		$this.config.skipScanFarm = $false
		$this.config.RemoveNote($this.GetType().Name)
	}
}

[ConfigAttribute(("clusterCertificateAuthorityCertPath","csrSignerName","skipScanFarm","skipTls","webServicePortNumber"))]
class ScanFarmTlsRemoval : Step {

	static [string] hidden $description = @'
You cannot use TLS between SRM components when using the scan farm
feature. Your component TLS configuration must be removed. 
'@

	ScanFarmTlsRemoval([Config] $config) : base(
		[ScanFarmTlsRemoval].Name, 
		$config,
		'Scan Farm TLS Removal',
		[ScanFarmTlsRemoval]::description,
		'Do you want to continue?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, 
			[tuple]::create('&Yes', 'Yes, I want to remove my TLS config'),
			-1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		# override TLS settings to support add-scanfarm use case
		$this.config.skipTls = $true
		$this.config.webServicePortNumber = 9090
		$this.config.clusterCertificateAuthorityCertPath = ''
		$this.config.csrSignerName = ''

		$annotations = $this.config.GetIngressAnnotations()

		$nginxBackend = $annotations['nginx.ingress.kubernetes.io/backend-protocol']
		if ($null -ne $nginxBackend) {
			$this.config.SetIngressAnnotation('nginx.ingress.kubernetes.io/backend-protocol', 'HTTP')
		}
		
		$awsBackend = $annotations['service.beta.kubernetes.io/aws-load-balancer-backend-protocol']
		if ($null -ne $awsBackend) {
			$this.config.SetIngressAnnotation('service.beta.kubernetes.io/aws-load-balancer-backend-protocol', 'HTTP')
		}

		# remove installation note related to TLS
		$this.config.RemoveNote('UseTlsOption')

		return $true
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and -not $this.config.skipTls
	}
}

[ConfigAttribute(("repoUsername","skipScanFarm"))]
class RepoUsername : Step {

	static [string] hidden $description = @'
To use the Scan Farm feature, you must provide a username and password
for the Black Duck Docker Registry. You can obtain your credential by
clicking the 'View/Request Docker Registry Credential' button in the
Black Duck Community portal.

If you are new to Black Duck, request access to Black Duck Community
at https://community.blackduck.com/s/SelfRegistrationForm. Complete and
submit the registration form, and you should receive access instantaneously.

Your credential is the same one you will use to copy Docker images from
the Black Duck Docker registry to your private Docker registry.
'@

	RepoUsername([Config] $config) : base(
		[RepoUsername].Name, 
		$config,
		'Black Duck Docker Repo Username',
		[RepoUsername]::description,
		'Enter your Black Duck Docker Repo username') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.repoUsername = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.repoUsername = ''
	}
	
	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("repoPwd","skipScanFarm"))]
class RepoPassword : Step {

	static [string] hidden $description = @'
To use the Scan Farm feature, you must provide a username and password
for the Black Duck Docker Registry. You can obtain your credential by
clicking the 'View/Request Docker Registry Credential' button in the
Black Duck Community portal.

If you are new to Black Duck, request access to Black Duck Community
at https://community.blackduck.com/s/SelfRegistrationForm. Complete and
submit the registration form, and you should receive access instantaneously.

Your credential is the same one you will use to copy Docker images from
the Black Duck Docker registry to your private Docker registry.
'@

	RepoPassword([Config] $config) : base(
		[RepoPassword].Name, 
		$config,
		'Black Duck Docker Repo Password',
		[RepoPassword]::description,
		'Enter your Black Duck Docker Repo password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.repoPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.repoPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

class WelcomeScanFarm : Step {

	WelcomeScanFarm([Config] $config) : base(
		[WelcomeScanFarm].Name,
		$config,
		'',
		'',
		'') {}

	[bool]Run() {
        Write-Host '  ______       _______         ____    ____  '
        Write-Host '.'' ____ \     |_   __ \       |_   \  /   _|'
        Write-Host '| (___ \_|      | |__) |        |   \/   |   '
        Write-Host ' _.____`.       |  __ /         | |\  /| |   '
        Write-Host '| \____) |     _| |  \ \_      _| |_\/_| |_  '
        Write-Host ' \______.''    |____| |___|    |_____||_____|'
		Write-Host @'

Welcome to the Software Risk Manager Add Scan Farm Wizard!

This wizard helps you specify your SRM scan farm configuration
by updating the config.json file that you use with the Helm
Prep script to stage your helm deployment.

'@
		Read-HostEnter
		return $true
	}
}

[ConfigAttribute(("skipScanFarm"))]
class AbortScanFarm : Step {

	AbortScanFarm([Config] $config) : base(
		[AbortScanFarm].Name,
		$config,
		'',
		'',
		'') {}

	[bool]Run() {
		Write-Host 'Setup aborted'
		return $true
	}

	[bool]CanRun() {
		return $this.config.skipScanFarm
	}
}
