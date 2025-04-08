[ConfigAttribute(("useGeneratedPwds"))]
class GeneratePwds : Step {

	static [string] hidden $description = @'
SRM can auto-generate the remaining passwords and keys, so you don't 
have to specify them individually. The notes provided at deployment 
time will include a command that you can use to fetch the auto-generated 
SRM admin password.
'@

	GeneratePwds([Config] $config) : base(
		[GeneratePwds].Name, 
		$config,
		'Auto-Generated Passwords',
		[GeneratePwds]::description,
		'Do you want to use auto-generated passwords and keys?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to use auto-generated passwords/keys',
			'No, I don''t want to use auto-generated passwords/keys', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useGeneratedPwds = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.useGeneratedPwds = $false
	}
}

[ConfigAttribute(("mariadbRootPwd","skipDatabase","useGeneratedPwds"))]
class DatabaseRootPwd : Step {

	static [string] hidden $description = @'
Specify the password for the MariaDB root user.
'@

	DatabaseRootPwd([Config] $config) : base(
		[DatabaseRootPwd].Name, 
		$config,
		'Database Root Password',
		[DatabaseRootPwd]::description,
		'Enter a password for the MariaDB root user') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.blacklist = @("'")
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.mariadbRootPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.mariadbRootPwd = ''
	}

    [bool]CanRun(){
		return -not $this.config.skipDatabase -and -not $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("dbSlaveReplicaCount","mariadbReplicatorPwd","skipDatabase","useGeneratedPwds"))]
class DatabaseReplicationPwd : Step {

	static [string] hidden $description = @'
Specify the password for the MariaDB replication user.
'@

	DatabaseReplicationPwd([Config] $config) : base(
		[DatabaseReplicationPwd].Name, 
		$config,
		'Database Replication Password',
		[DatabaseReplicationPwd]::description,
		'Enter a password for the MariaDB replicator user') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.blacklist = @("'")
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.mariadbReplicatorPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.mariadbReplicatorPwd = ''
	}

    [bool]CanRun(){
		return (-not $this.config.skipDatabase) -and ($this.config.dbSlaveReplicaCount -gt 0) -and -not $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("skipDatabase","srmDatabaseUserPwd","useGeneratedPwds"))]
class DatabaseUserPwd : Step {

	static [string] hidden $description = @'
Specify the password for the 'codedx' database user account to access the SRM 
database.
'@

	DatabaseUserPwd([Config] $config) : base(
		[DatabaseUserPwd].Name, 
		$config,
		'SRM Database User Password',
		[DatabaseUserPwd]::description,
		"Enter a password for the SRM database user account") {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.srmDatabaseUserPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.srmDatabaseUserPwd = ''
	}

    [bool]CanRun(){
		return -not $this.config.skipDatabase -and -not $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("adminPwd","useGeneratedPwds"))]
class AdminPassword : Step {

	static [string] hidden $description = @'
Specify the password you want to use for the SRM admin account. The 
password must be at least eight characters long.
'@
	
    AdminPassword([Config] $config) : base(
		[AdminPassword].Name, 
		$config,
		'SRM Password',
		[AdminPassword]::description,
		'Enter a password for the SRM admin account') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.adminPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.adminPwd = ''
	}

	[bool]CanRun(){
		return -not $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("skipToolOrchestration","toolServiceApiKey","useGeneratedPwds"))]
class ToolServiceKey : Step {

	static [string] hidden $description = @'
Specify the key you want to use for the SRM Tool Service. The key provides 
admin access to the tool orchestration system. The key must be at least eight 
characters long.
'@

	ToolServiceKey([Config] $config) : base(
		[ToolServiceKey].Name, 
		$config,
		'SRM Tool Service Password',
		[ToolServiceKey]::description,
		'Enter SRM Tool Service API key/password') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.toolServiceApiKey = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.toolServiceApiKey = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration -and -not $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("minioAdminPwd","skipMinIO","skipToolOrchestration","useGeneratedPwds"))]
class MinioAdminPassword : Step {

	static [string] hidden $description = @'
Specify the password you want to use for the MinIO admin account. The 
password must be at least eight characters long.
'@

	MinioAdminPassword([Config] $config) : base(
		[MinioAdminPassword].Name, 
		$config,
		'MinIO Password',
		[MinioAdminPassword]::description,
		'Enter a password for the MinIO admin account') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.minioAdminPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.minioAdminPwd = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO -and -not $this.config.useGeneratedPwds
	}
}

class WelcomePasswords : Step {

	WelcomePasswords([Config] $config) : base(
		[WelcomePasswords].Name,
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

Welcome to the Software Risk Manager Set Password Wizard!

This wizard helps you change the component passwords for the Core
and Tool Orchestration features.

Note: You must specify all requested passwords, but you can reuse
existing ones if you do not want to change a particular password.

'@
		Read-HostEnter
		return $true
	}
}

[ConfigAttribute(("useGeneratedPwds"))]
class AbortPasswords : Step {

	AbortPasswords([Config] $config) : base(
		[AbortPasswords].Name,
		$config,
		'',
		'',
		'') {}

	[bool]Run() {
		Write-Host 'Setup aborted'
		return $true
	}

	[bool]CanRun() {
		return $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("useGeneratedPwds"))]
class UseAutoGeneratedPwds : Step {

	static [string] hidden $description = @'
You previously auto-generated passwords and keys for supported Software
Risk Manager features. You must discontinue using generated passwords
and keys when specifying new passwords.
'@

	UseAutoGeneratedPwds([Config] $config) : base(
		[UseAutoGeneratedPwds].Name, 
		$config,
		'Auto-Generated Passwords',
		[UseAutoGeneratedPwds]::description,
		'Do you want to discontinue using auto-generated passwords/keys?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, continue to reset auto-generated passwords/keys',
			'No, do not reset passwords/keys', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useGeneratedPwds = ([YesNoQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset(){
		$this.config.useGeneratedPwds = $true
	}

	[bool]CanRun(){
		return $this.config.useGeneratedPwds
	}
}

[ConfigAttribute(("adminPwd","useGeneratedPwds"))]
class ResetAdminPassword : Step {

	static [string] hidden $description = @'
Specify the new password you want to use for the SRM admin account. The
password must meet the following criteria:

 - Be at least 12 characters
 - Include lower case (a-z)
 - Include upper case (A-Z)
 - Include number (0-9)
 - Include a special character (!@#%^&*()-_+.$)

Additionally, SRM will apply the following criteria when you attempt
to change your password using the web application or API:
 
 - Not be common
 - Password and username are not the same
 - Be distinct from previous 10 passwords
 - Be different than the current password
'@

	static [string] $validationError = 'Value does not meet password requirements'

    ResetAdminPassword([Config] $config) : base(
		[ResetAdminPassword].Name, 
		$config,
		'SRM Password',
		[ResetAdminPassword]::description,
		'Enter a password for the SRM admin account') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		return $question
	}
	
	[bool]HandleResponse([IQuestion] $question) {

		$response = ([ConfirmationQuestion]$question).response

		$meetsPwdRequirements = $true
		'.{12,}','[A-Z]','[a-z]','[0-9]','[!@\#%\^&\*\(\)\-_\+\.\$]' | ForEach-Object {
			$meetsPwdRequirements = $meetsPwdRequirements -and ($response -match $_)
		}
		if (-not $meetsPwdRequirements) {
			Write-Host ([ResetAdminPassword]::validationError)
			return $false
		}

		$this.config.adminPwd = $response
		return $true
	}

	[void]Reset(){
		$this.config.adminPwd = ''
	}

	[bool]CanRun(){
		return -not $this.config.useGeneratedPwds
	}
}

class ResetPwdProcedure : Step {

	ResetPwdProcedure(
		[string] $name,
		[string] $title,
		[string] $description,
		[Config] $config) : base(
			$name, 
			$config,
			$title,
			$description,
			'Did you complete the above steps?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, continue to next step',
			'No, continue with this step', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return ([YesNoQuestion]$question).choice -eq 0
	}
}

class ResetWebPwdProcedure : ResetPwdProcedure {

	static [string] hidden $description = @'
Follow these steps to reset your Software Risk Manager web admin
password:

1) Log on to the Software Risk Manager web application as the
   admin user and visit /srm/me, click Password, and update your
   password to match what you entered in this wizard.
   Alternatively, you can set a new admin password by using the
   Software Risk Manager web API at /x/profile/password.

2) Scale the web application Deployment to 0 replicas, ending the
   web application pod. It will remain off until you rerun the kubectl
   and helm commands printed later on by the Helm Prep script.

Note: Take care to enter the correct, new admin password in the web
application or via the web API.
'@

	ResetWebPwdProcedure([Config] $config) : base(
		[ResetWebPwdProcedure].Name,
		'Reset Web Password Procedure',
		[ResetWebPwdProcedure]::description,
		$config) {}
}

[ConfigAttribute(("dbSlaveReplicaCount","skipDatabase"))]
class ResetReplicaDBPwdProcedure : ResetPwdProcedure {

	static [string] hidden $description = @'
Follow these steps to reset your MariaDB passwords on your MariaDB
replica instance (i.e., not your MariaDB master/primary instance):

1) Log on to your replica database pod and start a new session using
   this mysql commmand: mysql -uroot -p

2) Enter your current MariaDB password at the prompt.

3) Run the following database statements, replacing the placeholder
   passwords by matching what you entered on previous screens:

   SET PASSWORD FOR 'codedx'@'%' = PASSWORD('new-codedx-user-password');
   SET PASSWORD FOR 'replicator'@'%' = PASSWORD('new-replicator-password');
   SET PASSWORD FOR 'root'@'%' = PASSWORD('new-root-password');

4) Scale the database replica/slave StatefulSet to 0 replicas, ending the
   replica database pod. It will remain off until you rerun the kubectl
   and helm commands printed later on by the Helm Prep script.

Note: Take care to enter the correct, new database passwords. The database pod
may enter a failed state between changing the root password and scaling the
StatefulSet to zero replicas.
'@

	ResetReplicaDBPwdProcedure([Config] $config) : base(
		[ResetReplicaDBPwdProcedure].Name,
		'Reset Replica DB Password Procedure',
		[ResetReplicaDBPwdProcedure]::description,
		$config) {}

	[bool]CanRun() {
		return (-not $this.config.skipDatabase) -and ($this.config.dbSlaveReplicaCount -gt 0)
	}
}

[ConfigAttribute(("dbSlaveReplicaCount","skipDatabase"))]
class ResetMasterDBPwdProcedure : ResetPwdProcedure {

	static [string] hidden $descriptionBefore = @'
Follow these steps to reset your MariaDB passwords on your MariaDB
master instance (i.e., not your MariaDB replica instance):

1) Log on to your master database pod and start a new session using
   this mysql commmand: mysql -uroot -p

2) Enter your current MariaDB password at the prompt.

3) Run the following database statements, replacing the placeholder
   passwords by matching what you entered on previous screens:

'@

	static [string] hidden $resetUserStatement = @'

   SET PASSWORD FOR 'codedx'@'%' = PASSWORD('new-codedx-user-password');
'@

	static [string] hidden $resetReplicatorStatement = @'

   SET PASSWORD FOR 'replicator'@'%' = PASSWORD('new-replicator-password');
'@

	static [string] hidden $rootReplicatorStatement = @'

   SET PASSWORD FOR 'root'@'%' = PASSWORD('new-root-password');
'@

	static [string] hidden $descriptionAfter = @'


4) Scale the database master StatefulSet to 0 replicas, ending the
   master database pod. It will remain off until you rerun the kubectl
   and helm commands printed later on by the Helm Prep script.

Note: Take care to enter the correct, new database passwords. The database pod
may enter a failed state between changing the root password and scaling the
StatefulSet to zero replicas.
'@

	ResetMasterDBPwdProcedure([Config] $config) : base(
		[ResetMasterDBPwdProcedure].Name,
		'Reset Master DB Password Procedure',
		[ResetMasterDBPwdProcedure]::description,
		$config) {}

	[bool]CanRun() {
		return -not $this.config.skipDatabase
	}

	[string]GetMessage() {
		return [ResetMasterDBPwdProcedure]::descriptionBefore + 
			[ResetMasterDBPwdProcedure]::resetUserStatement + 
			($this.config.dbSlaveReplicaCount -gt 0 ? [ResetMasterDBPwdProcedure]::resetReplicatorStatement : '') + 
			[ResetMasterDBPwdProcedure]::rootReplicatorStatement + 
			[ResetMasterDBPwdProcedure]::descriptionAfter
	}
}

[ConfigAttribute(("externalDatabaseUser","skipDatabase"))]
class ResetExternalDatabaseProcedure : ResetPwdProcedure {

	static [string] hidden $description = @'
Follow this step to reset your External Software Risk Manager database:

1) Log on to your external database and run the following command,
   replacing the password with your new database user passord:

'@

	ResetExternalDatabaseProcedure([Config] $config) : base(
		[ResetExternalDatabaseProcedure].Name,
		'Reset External DB User Procedure',
		[ResetExternalDatabaseProcedure]::description,
		$config) {}

	[bool]CanRun() {
		return $this.config.skipDatabase -and $this.config.externalDatabaseAuthType -eq [ExternalDatabaseAuthType]::Password
	}

	[string]GetMessage() {
		return [ResetExternalDatabaseProcedure]::description + 
			"`n   MariaDB: SET PASSWORD FOR '$($this.config.externalDatabaseUser)'@'%' = PASSWORD('new-db-user-password');" +
			"`n   MySQL:   SET PASSWORD FOR '$($this.config.externalDatabaseUser)'@'%' = 'new-db-user-password';"
	}
}

[ConfigAttribute(("skipToolOrchestration"))]
class ResetToolServiceKeyProcedure : ResetPwdProcedure {

	static [string] hidden $description = @'
Follow this step to reset your Software Risk Manager Tool Service
key:

1) Scale the tool service Deployment to 0 replicas, ending the
   tool service pod(s). It/they will remain off until you rerun the
   kubectl and helm commands printed later on by the Helm Prep script.
'@

	ResetToolServiceKeyProcedure([Config] $config) : base(
		[ResetToolServiceKeyProcedure].Name,
		'Reset Tool Service Key Procedure',
		[ResetToolServiceKeyProcedure]::description,
		$config) {}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration
	}
}

[ConfigAttribute(("skipMinIO","skipToolOrchestration"))]
class ResetMinIOPwdProcedure : ResetPwdProcedure {

	static [string] hidden $description = @'
Follow this step to reset your Software Risk Manager workflow storage
admin password:

1) Scale the MinIO Deployment to 0 replicas, ending the MinIO pod. It
   will remain off until you rerun the kubectl and helm commands
   printed later on by the Helm Prep script.
'@

	ResetMinIOPwdProcedure([Config] $config) : base(
		[ResetMinIOPwdProcedure].Name,
		'Reset MinIO Admin Password Procedure',
		[ResetMinIOPwdProcedure]::description,
		$config) {}

	[bool]CanRun() {
		return -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO
	}
}

class PwdProcedureOverview : Step {

	static [string] hidden $description = @'
The screens that follow will include manual steps you must take to
apply the password changes you made. You must take the required
actions before moving to the next screen.

Note: When specifying passwords referenced by manual steps, be careful
to specify the same passwords you entered earlier. Your system will not
work correctly if entered passwords do not match those referenced by the
following steps.
'@

	PwdProcedureOverview([Config] $config) : base(
		[PwdProcedureOverview].Name,
		$config,
		'Password Procedure Overview',
		[PwdProcedureOverview]::description,
		'Are you ready to proceed?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I''m ready to proceed',
			'No, I''m not ready to proceed', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return ([YesNoQuestion]$question).choice -eq 0
	}
}

class PwdProcedureWrapUp : Step {

	static [string] hidden $description = @'
On the next screen, you will generate the config.json file that you
will use to run the Helm Prep script to produce helm commands, value(s)
files, and any required prerequisite K8s YAML resources.

Your system will be back online after you finish running the required
commands printed by the Helm Prep script. If a Deployment or StatefulSet
resource does not return to its original replica count, adjust it
accordingly after running helm.
'@

	PwdProcedureWrapUp([Config] $config) : base(
		[PwdProcedureWrapUp].Name,
		$config,
		'Finishing Up',
		[PwdProcedureWrapUp]::description,
		'Are you ready to proceed?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I''m ready to proceed',
			'No, I''m not ready to proceed', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return ([YesNoQuestion]$question).choice -eq 0
	}
}
