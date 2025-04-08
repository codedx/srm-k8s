[ConfigAttribute(("skipDatabase"))]
class UseExternalDatabase : Step {

	static [string] hidden $description = @'
The SRM setup script can deploy a MariaDB database on your cluster, or 
you can choose to use your own database instance to host the SRM database. 

When using your own database, you must provide the database server, 
database catalog, and a database username and password. You must also 
provide a certificate for your database CA if you want to use TLS to 
secure the communication between SRM and your database (recommended).

If you plan to use an external database for the SRM Web component, complete
the External Web Database pre-work before continuing:

https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md#external-web-database-pre-work
'@

	UseExternalDatabase([Config] $config) : base(
		[UseExternalDatabase].Name, 
		$config,
		'External Database',
		[UseExternalDatabase]::description,
		'Do you want to host your SRM database on an external database server that you provide?') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I want to use a database that I will provide', 
			'No, I want to use the database that SRM deploys on Kubernetes', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.skipDatabase = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.skipDatabase = $false
	}
}

[ConfigAttribute(("dbSlaveReplicaCount","skipDatabase"))]
class DatabaseReplicaCount : Step {

	static [string] hidden $description = @'
Specify the number of subordinate, read-only databases that will use MariaDB 
data replication to store a copy of the MariaDB master database.

A replica database can provide a way for you to configure a database backup
for your SRM database using a tool like Verlero.

Note: If you are not planning to back up this SRM deployment, set the 
number of database replicas to 0.
'@

	DatabaseReplicaCount([Config] $config) : base(
		[DatabaseReplicaCount].Name, 
		$config,
		'Database Replicas',
		[DatabaseReplicaCount]::description,
		'Enter the number of database replicas') {}
	
	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object IntegerQuestion($prompt, 0, 5, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.dbSlaveReplicaCount = ([IntegerQuestion]$question).intResponse
		return $true
	}

	[void]Reset(){
		$this.config.dbSlaveReplicaCount = 1
	}

	[bool]CanRun() {
		return -not $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabaseHost","skipDatabase"))]
class ExternalDatabaseHost : Step {

	static [string] hidden $description = @'
Specify the external database host that you are using to host your SRM 
database. If you're using an AWS RDS database, your host will have a name like
server.region.rds.amazonaws.com.
'@

	ExternalDatabaseHost([Config] $config) : base(
		[ExternalDatabaseHost].Name, 
		$config,
		'External Database Host',
		[ExternalDatabaseHost]::description,
		'Enter the name of your external database host') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalDatabaseHost = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabaseHost = ''
	}

	[bool]CanRun() {
		return $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabasePort","skipDatabase"))]
class ExternalDatabasePort : Step {

	static [string] hidden $description = @'
Specify the port that your external database host is listening to for incoming 
connections. 

Note: The default port for MariaDB is 3306.
'@

	ExternalDatabasePort([Config] $config) : base(
		[ExternalDatabasePort].Name, 
		$config,
		'External Database Port',
		[ExternalDatabasePort]::description,
		'Enter your database port or press Enter to accept the default (3306)') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object IntegerQuestion($prompt, 0, 65535, $false)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [IntegerQuestion]$question
		$this.config.externalDatabasePort = $q.isResponseEmpty ? 3306 : $q.intResponse
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabasePort = [Config]::externalDatabasePortDefault
	}

	[bool]CanRun() {
		return $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabaseName","skipDatabase"))]
class ExternalDatabaseName : Step {

	static [string] hidden $description = @'
Specify the name of the SRM database you previously created on your 
external database server. For example, enter srmdb if you previously ran 
a CREATE DATABASE statement with that name during the SRM external 
database setup instructions.
'@

	ExternalDatabaseName([Config] $config) : base(
		[ExternalDatabaseName].Name, 
		$config,
		'External Database Name',
		[ExternalDatabaseName]::description,
		'Enter the name of your SRM database or press Enter to accept the default (srmdb)') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [Question]$question
		$this.config.externalDatabaseName = $q.isResponseEmpty ? 'srmdb' : $q.response
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabaseName = ''
	}

	[bool]CanRun() {
		return $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabaseUser","skipDatabase"))]
class ExternalDatabaseUser : Step {

	static [string] hidden $description = @'
Specify the username for the user with access to your SRM database. For 
example, enter srm if you previously ran a CREATE USER statement with that 
name during the SRM external database setup instructions.
'@

	ExternalDatabaseUser([Config] $config) : base(
		[ExternalDatabaseUser].Name, 
		$config,
		'External Database Username',
		[ExternalDatabaseUser]::description,
		'Enter the SRM database username or press Enter to accept the default (srm)') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [Question]$question
		$this.config.externalDatabaseUser = $q.isResponseEmpty ? 'srm' : $q.response
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabaseUser = ''
	}

	[bool]CanRun() {
		return $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabasePwd","skipDatabase"))]
class ExternalDatabasePwd : Step {

	static [string] hidden $description = @'
Specify the password for the user with access to your SRM database. Enter
the password you specified with the IDENTIFIED BY portion of the CREATE USER 
statement you ran during the SRM external database setup instructions.
'@

	ExternalDatabasePwd([Config] $config) : base(
		[ExternalDatabasePwd].Name, 
		$config,
		'External Database Password',
		[ExternalDatabasePwd]::description,
		'Enter the SRM database password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalDatabasePwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabasePwd = ''
	}

	[bool]CanRun() {
		return $this.config.skipDatabase -and $this.config.externalDatabaseAuthType -eq [ExternalDatabaseAuthType]::Password
	}
}

[ConfigAttribute(("externalDatabaseSkipTls","skipDatabase"))]
class ExternalDatabaseOneWayAuth : Step {

	static [string] hidden $description = @'
Specify whether you want to enable two-way encryption with server-side 
certificate authentication so that you can protect the communicaitons 
between SRM and your database server.

Note: To enable this option, you must have access to the certificate 
associated with your database CA.
'@

	ExternalDatabaseOneWayAuth([Config] $config) : base(
		[ExternalDatabaseOneWayAuth].Name, 
		$config,
		'External Database Authentication',
		[ExternalDatabaseOneWayAuth]::description,
		'Use one-way server-side authentication to protect your database connection with TLS?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, I have a CA certificate and want to configure TLS for database connections',
			'No, I do not want to configure TLS', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalDatabaseSkipTls = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}	

	[void]Reset(){
		$this.config.externalDatabaseSkipTls = $false
	}

	[bool]CanRun() {
		return $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabaseSkipTls","externalDatabaseTrustCert","skipDatabase"))]
class ExternalDatabaseTrustCert : Step {

	static [string] hidden $description = @'
Specify whether your external database uses a certificate not issued
by a well-known certificate authority (e.g., AWS RDS). If so, you
will need to specify a file that includes the endpoint's certificate
chain.
'@

	ExternalDatabaseTrustCert([Config] $config) : base(
		[ExternalDatabaseTrustCert].Name, 
		$config,
		'External Database Trust',
		[ExternalDatabaseTrustCert]::description,
		'Do you need to provide your database''s certificate chain?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt, 
			'Yes, my external database uses a certificate not issued by a well-known CA', 
			'No, my external database uses a certificate issued by a well-known CA', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalDatabaseTrustCert = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabaseTrustCert = $false
	}

	[bool]CanRun() {
		return -not $this.config.externalDatabaseSkipTls -and $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabaseServerCert","externalDatabaseTrustCert"))]
class ExternalDatabaseCert : Step {

	static [string] hidden $description = @'
Specify a file path to the CA associated with your database host.

If you're using an AWS RDS database, you can download your AWS CA
certificate from the following URL:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html

If you're using an Azure Database, use the following URL to locate the
certificate download link:
https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-connect-tls-ssl
'@

	static [string] hidden $descriptionRdsIam = @'
Specify a file path to the CA cert for your AWS RDS database host.

You can download your AWS CA certificate from the following URL:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html
'@

	ExternalDatabaseCert([Config] $config) : base(
		[ExternalDatabaseCert].Name, 
		$config,
		'External Database Cert',
		'',
		'Enter path to certificate to the certificate of your database CA') {}

	[string]GetMessage() {
		return $this.config.externalDatabaseAuthType -eq [ExternalDatabaseAuthType]::RdsIam ?
			[ExternalDatabaseCert]::descriptionRdsIam : [ExternalDatabaseCert]::description
	}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.externalDatabaseServerCert = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.externalDatabaseServerCert = ''
	}

	[bool]CanRun() {
		return $this.config.externalDatabaseTrustCert
	}
}

[ConfigAttribute(("externalDatabaseAuthType","externalDatabaseTrustCert","skipDatabase"))]
class ExternalDatabaseAuth : Step {

	static [string] hidden $description = @'
Specify the type of authentication SRM will use to connect to your external
database. If you are using an AWS RDS MariaDB or MySQL database, you can
use AWS RDS IAM authentication. Otherwise, choose password authentication
to authenticate using a database password you will provide. Refer to the
appropriate database pre-work sections in the SRM Kubernetes Deployment Guide.
'@

	ExternalDatabaseAuth([Config] $config) : base(
		[ExternalDatabaseAuth].Name, 
		$config,
		'External Database Authentication',
		[ExternalDatabaseAuth]::description,
		'How will SRM authenticate with the database?') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$choices = @(
			[tuple]::create('Password', 'I will provide a password for database authentication')
			[tuple]::create('AWS IAM', 'I will configure AWS IAM authentication for database authentication')
		)
		return new-object MultipleChoiceQuestion($prompt, $choices, 0)
	}
	
	[bool]HandleResponse([IQuestion] $question) {

		switch (([MultipleChoiceQuestion]$question).choice) {
			0 {
				$this.config.externalDatabaseAuthType = $this.config.externalDatabaseAuthType = [ExternalDatabaseAuthType]::Password
			}
			1 {
				$this.config.externalDatabaseTrustCert = $true
				$this.config.externalDatabaseAuthType = $this.config.externalDatabaseAuthType = [ExternalDatabaseAuthType]::RdsIam
			}
		}
		return $true
	}
	
	[void]Reset(){
		$this.config.externalDatabaseTrustCert = $false
		$this.config.externalDatabaseAuthType = [ExternalDatabaseAuthType]::Password
	}

	[bool]CanRun() {
		return $this.config.skipDatabase
	}
}

[ConfigAttribute(("externalDatabaseAuthType","skipDatabase","skipWebServiceAccountCreate","webServiceAccountName"))]
class ExternalDatabaseServiceAccount : Step {

	static [string] hidden $description = @'
Specify the name of the Kubernetes ServiceAccount you created when you
followed the pre-work listed in the SRM Kubernetes Deployment Guide
under the "External Web Database Pre-work - RDS IAM Authentication"
section.
'@

	ExternalDatabaseServiceAccount([Config] $config) : base(
		[ExternalDatabaseServiceAccount].Name, 
		$config,
		'External Database Service Account Name',
		[ExternalDatabaseServiceAccount]::description,
		'Enter the name of the Kubernetes ServiceAccount resource you created') {}

	[bool]HandleResponse([IQuestion] $question) {
		$q = [Question]$question
		$this.config.webServiceAccountName = $q.response
		$this.config.skipWebServiceAccountCreate = $true
		return $true
	}

	[void]Reset(){
		$this.config.webServiceAccountName = ''
		$this.config.skipWebServiceAccountCreate = $true
	}

	[bool]CanRun() {
		return $this.config.skipDatabase -and $this.config.externalDatabaseAuthType -eq [ExternalDatabaseAuthType]::RdsIam
	}
}
