[ConfigAttribute(("scanFarmDatabaseHost","skipScanFarm"))]
class ScanFarmDatabaseHost : Step {

	static [string] hidden $description = @'
SRM saves and manages scan farm data in a PostgreSQL database you must
provide. Black Duck recommends using a cloud-provider DBaaS (e.g., AWS RDS,
Azure Database for PostgreSQL, Google Cloud SQL).

Your PostgreSQL database instance must permit network traffic from both
the storage and scan service.

Note: Locate your database near the scan farm software to improve performance.
'@
	
	ScanFarmDatabaseHost([Config] $config) : base(
		[ScanFarmDatabaseHost].Name, 
		$config,
		'Scan Farm PostgreSQL Host',
		[ScanFarmDatabaseHost]::description,
		'Enter the name of your PostgreSQL database host') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmDatabaseHost = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmDatabaseHost = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmDatabasePort","skipScanFarm"))]
class ScanFarmDatabasePort : Step {

	static [string] hidden $description = @'
Specify the port that your external PostgreSQL database host is listening
to for incoming connections.

Note: The default port for PostgreSQL is 5432.
'@

	ScanFarmDatabasePort([Config] $config) : base(
		[ScanFarmDatabasePort].Name, 
		$config,
		'Scan Farm PostgreSQL Port',
		[ScanFarmDatabasePort]::description,
		'Enter your PostgreSQL port or press Enter to accept the default (5432)') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object IntegerQuestion($prompt, 0, 65535, $false)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [IntegerQuestion]$question
		$this.config.scanFarmDatabasePort = $q.isResponseEmpty ? 5432 : $q.intResponse
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmDatabasePort = [Config]::externalDatabasePortDefault
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmDatabaseUser","skipScanFarm"))]
class ScanFarmDatabaseUsername : Step {

	static [string] hidden $description = @'
Specify the username for your external PostgreSQL database.
'@

	ScanFarmDatabaseUsername([Config] $config) : base(
		[ScanFarmDatabaseUsername].Name, 
		$config,
		'Scan Farm PostgreSQL Username',
		[ScanFarmDatabaseUsername]::description,
		'Enter the username for your PostgreSQL database') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmDatabaseUser = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmDatabaseUser = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmDatabasePwd","skipScanFarm"))]
class ScanFarmDatabasePwd : Step {

	static [string] hidden $description = @'
Specify the password for the user with access to your external PostgreSQL
database.
'@

	ScanFarmDatabasePwd([Config] $config) : base(
		[ScanFarmDatabasePwd].Name, 
		$config,
		'Scan Farm PostgreSQL Password',
		[ScanFarmDatabasePwd]::description,
		'Enter the password of your PostgreSQL database user') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmDatabasePwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmDatabasePwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmDatabaseSslMode","skipScanFarm"))]
class ScanFarmDatabaseTls : Step {

	static [string] hidden $description = @'
Specify whether you want to enable two-way encryption with server-side 
certificate authentication so that you can protect the communicaitons 
between the Scan Farm and your external PostgreSQL server. To enable
TLS, you must have access to the certificate associated with your
database CA.

Note: Do not use verify-full for Google Cloud SQL as there might be issues
related to specifying a hostname in the certificate.
'@

	ScanFarmDatabaseTls([Config] $config) : base(
		[ScanFarmDatabaseTls].Name, 
		$config,
		'Scan Farm PostgreSQL TLS',
		[ScanFarmDatabaseTls]::description,
		'Specify the SSL/TLS mode for your PostgreSQL database connection') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Disable', 'Do not use TLS'),
			[tuple]::create('&Verify-CA', 'Use PostgreSQL verify-ca setting'),
			[tuple]::create('Verify-&Full', 'Use PostgreSQL verify-full setting')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.scanFarmDatabaseSslMode = 'disable' }
			1 { $this.config.scanFarmDatabaseSslMode = 'verify-ca' }
			2 { $this.config.scanFarmDatabaseSslMode = 'verify-full' }
		}
		return $true
	}	

	[void]Reset(){
		$this.config.scanFarmDatabaseSslMode = 'disable'
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmDatabaseServerCert","scanFarmDatabaseSslMode","skipScanFarm"))]
class ScanFarmDatabaseCert : Step {

	static [string] hidden $description = @'
Specify a file path to the CA file for your PostgreSQL host.
'@

	ScanFarmDatabaseCert([Config] $config) : base(
		[ScanFarmDatabaseCert].Name, 
		$config,
		'Scan Farm PostgreSQL Cert',
		[ScanFarmDatabaseCert]::description,
		'Enter the path to the certificate of your database CA') {}
	
	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmDatabaseServerCert = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmDatabaseServerCert = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm -and $this.config.scanFarmDatabaseSslMode -ne 'disable'
	}
}

[ConfigAttribute(("scanFarmScanDatabaseCatalog","skipScanFarm"))]
class ScanFarmScanServiceDatabaseName : Step {

	static [string] hidden $description = @'
Specify the name of the existing PostgreSQL database catalog that you
will use for the Scan Farm Scan Service for your external PostgreSQL
database.

Note: If the database doesn't already exist, an attempt will be made
to provision the database using the credential you provided.
'@

	ScanFarmScanServiceDatabaseName([Config] $config) : base(
		[ScanFarmScanServiceDatabaseName].Name, 
		$config,
		'Scan Service PostgreSQL Catalog',
		[ScanFarmScanServiceDatabaseName]::description,
		'Enter the name of your Scan Service database catalog') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmScanDatabaseCatalog = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmScanDatabaseCatalog = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}

[ConfigAttribute(("scanFarmStorageDatabaseCatalog","skipScanFarm"))]
class ScanFarmStorageServiceDatabaseName : Step {

	static [string] hidden $description = @'
Specify the name of the existing PostgreSQL database catalog that you
will use for the Scan Farm Storage Service for your external PostgreSQL
database.

Note: If the database doesn't already exist, an attempt will be made
to provision the database using the credential you provided.
'@

	ScanFarmStorageServiceDatabaseName([Config] $config) : base(
		[ScanFarmStorageServiceDatabaseName].Name, 
		$config,
		'Storage Service Database Catalog',
		[ScanFarmStorageServiceDatabaseName]::description,
		'Enter the name of your Storage Service database catalog') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.scanFarmStorageDatabaseCatalog = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.scanFarmStorageDatabaseCatalog = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipScanFarm
	}
}
