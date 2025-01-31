[ConfigAttribute(("useLdap","useSaml"))]
class AuthenticationType : Step {

	static [string] hidden $description = @'
By default, SRM users log on using a local account by specifying a 
username and password. SRM can also be configured to authenticate users 
against a SAML 2.0 Identity Provider (IdP) or an LDAP directory.
'@

	AuthenticationType([Config] $config) : base(
		[AuthenticationType].Name, 
		$config,
		'Authentication Type',
		[AuthenticationType]::description,
		'How will users authenticate to SRM?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&Local Accounts', 'Use local SRM accounts only'),
			[tuple]::create('&SAML', 'Use local SRM accounts and a SAML IdP'),
			[tuple]::create('L&DAP', 'Use local SRM accounts and an LDAP directory')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$multipleChoiceQuestion = ([MultipleChoiceQuestion]$question)
		$this.config.useSaml = $multipleChoiceQuestion.choice -eq 1
		$this.config.useLdap = $multipleChoiceQuestion.choice -eq 2
		return $true
	}

	[void]Reset(){
		$this.config.useSaml = $false
		$this.config.useLdap = $false
	}
}

[ConfigAttribute(("useLdap"))]
class LdapInstructions : Step {
	static [string] hidden $description = @'
SRM supports authentication against an LDAP directory, but you must 
manually configure LDAP.

Refer to the following URL for LDAP configuration instructions. Read the 
instructions at this time and remember to add any necessary certificates 
if you plan to use LDAPS:

https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md#specify-ldap-configuration
'@

	LdapInstructions([Config] $config) : base(
		[LdapInstructions].Name, 
		$config,
		'LDAP Authentication',
		[LdapInstructions]::description,
		'Do you want to continue?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, 
			[tuple]::create('&Yes', 'Yes, I will manually configure LDAP later on'),
			-1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}

	[bool]CanRun() {
		return $this.config.useLdap
	}
}

[ConfigAttribute(("samlHostBasePath","useSaml"))]
class SamlAuthenticationHostBasePath : Step {
	
	static [string] hidden $description = @'
Your SAML IdP will connect to your SRM instance using the SRM Assertion Consumer Service (ACS) 
endpoint, a URL that combines your host base path with 'login/callback/saml'.

For example, if you will access SRM over HTTPS at my-srm.blackduck.com with an /srm context
path, enter this as your SAML SRM host base path: https://my-srm.blackduck.com/srm

In the above example, your SAML IdP should permit login redirects to this URL:
https://my-srm.blackduck.com/srm/login/callback/saml

Note: Do not enter the /login/callback/saml portion here; enter the host base path only.
'@

	SamlAuthenticationHostBasePath([Config] $config) : base(
		[SamlAuthenticationHostBasePath].Name, 
		$config,
		'SAML SRM Host Base Path',
		[SamlAuthenticationHostBasePath]::description,
		'Enter your SAML SRM host base path') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlHostBasePath = ([Question]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlHostBasePath = ''
	}
}

[ConfigAttribute(("samlIdentityProviderMetadataPath","useSaml"))]
class SamlIdpMetadata : Step {

	static [string] hidden $description = @'
Specify the IdP metadata you downloaded from your SAML identity provider.
'@

	SamlIdpMetadata([Config] $config) : base(
		[SamlIdpMetadata].Name, 
		$config,
		'SAML Identity Provider Metadata',
		[SamlIdpMetadata]::description,
		'Enter IdP metadata path') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlIdentityProviderMetadataPath = ([PathQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlIdentityProviderMetadataPath = ''
	}
}

[ConfigAttribute(("samlAppName","samlHostBasePath","useSaml"))]
class SamlAppName : Step {

	static [string] hidden $description = @'
Specify the application name or ID that was previously registered with your 
SAML identity provider and is associated with your SRM application.
'@

	SamlAppName([Config] $config) : base(
		[SamlAppName].Name, 
		$config,
		'SAML Application Name',
		[SamlAppName]::description,
		'Enter SAML client ID/name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlAppName = ([Question]$question).response
		return $true
	}

	[string]GetMessage() {
		return $this.message + "`n`nYour SRM ACS endpoint will be $($this.config.samlHostBasePath)/login/callback/saml."
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlAppName = ''
	}
}

[ConfigAttribute(("samlKeystorePwd","useSaml"))]
class SamlKeystorePwd : Step {

	static [string] hidden $description = @'
Specify the password to protect the keystore that SRM will create to store 
the key pair that SRM will use to connect to your SAML identify provider.
'@

	SamlKeystorePwd([Config] $config) : base(
		[SamlKeystorePwd].Name, 
		$config,
		'SAML Keystore Password',
		[SamlKeystorePwd]::description,
		'Enter SAML keystore password') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlKeystorePwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlKeystorePwd = ''
	}
}

[ConfigAttribute(("samlPrivateKeyPwd","useSaml"))]
class SamlPrivateKeyPwd : Step {

	static [string] hidden $description = @'
Specify the password to protect the private key of the key pair that SRM 
will use to connect to your SAML identify provider.
'@

	SamlPrivateKeyPwd([Config] $config) : base(
		[SamlPrivateKeyPwd].Name, 
		$config,
		'SAML Private Key Password',
		[SamlPrivateKeyPwd]::description,
		'Enter SAML private key password') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		$question = new-object ConfirmationQuestion($prompt)
		$question.isSecure = $true
		$question.minimumLength = 8
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.samlPrivateKeyPwd = ([ConfirmationQuestion]$question).response
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}

	[void]Reset(){
		$this.config.samlPrivateKeyPwd = ''
	}
}

[ConfigAttribute(("useSaml"))]
class SamlExtraConfig : Step {
	static [string] hidden $description = @'
The setup script will configure the following SRM SAML properties based on 
the information you have provided thus far:

- auth.saml2.identityProviderMetadataPath
- auth.saml2.entityId
- auth.saml2.keystorePassword
- auth.saml2.privateKeyPassword
- auth.hostBasePath

You can find the entire list of SRM SAML properties at 
https://documentation.blackduck.com/bundle/srm/page/install_guide/SRMConfiguration/saml-props.html

To configure additional SAML properties, follow these instructions:
https://github.com/codedx/srm-k8s/blob/main/docs/DeploymentGuide.md#specify-extra-saml-configuration
'@

	SamlExtraConfig([Config] $config) : base(
		[SamlExtraConfig].Name, 
		$config,
		'SAML Extra Config',
		[SamlExtraConfig]::description,
		'Do you want to continue?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, 
			[tuple]::create('&Yes', 'Yes, continue to the next step'),
			-1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		return $true
	}

	[bool]CanRun() {
		return $this.config.useSaml
	}
}

class WelcomeAddSaml : Step {

	WelcomeAddSaml([Config] $config) : base(
		[WelcomeAddSaml].Name,
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

Welcome to the Software Risk Manager Add SAML Authentication Wizard!

This wizard helps you update the SRM Web component by adding
SAML configuration.

'@
		Read-HostEnter
		return $true
	}
}

[ConfigAttribute(("useSaml"))]
class UseSaml : Step {

	static [string] hidden $description = @'
Software Risk Manager can also be configured to authenticate against a SAML 2.0 IdP (Identity Provider).
'@

	UseSaml([Config] $config) : base(
		[UseSaml].Name,
		$config,
		'Use SAML Authentication',
		[UseSaml]::description,
		'Do you want to configure SAML authentication?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to configure SRM using SAML authentication.',
			'No, I do not want to configure SRM using SAML authentication.', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.useSaml = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.useSaml = $false
	}
}

[ConfigAttribute(("useSaml"))]
class AbortAddSaml : Step {

	AbortAddSaml([Config] $config) : base(
		[AbortAddSaml].Name,
		$config,
		'',
		'',
		'') {}

	[bool]Run() {
		Write-Host 'Setup aborted'
		return $true
	}

	[bool]CanRun() {
		return -not $this.config.useSaml
	}
}

[ConfigAttribute(("authCookieSecure"))]
class AuthCookieSecure : Step {

	static [string] hidden $description = @'
Software Risk Manager uses an authentication cookie whose Secure attribute
should be set when accessing the web application using HTTPS. The Secure
attribute must not be used if you plan to access the application with 
HTTP (not recommended) because it will block you from logging on.

Note: Answer 'No' if you plan to access Software Risk Manager via HTTP.
'@

	AuthCookieSecure([Config] $config) : base(
		[AuthCookieSecure].Name,
		$config,
		'Auth Cookie Secure',
		[AuthCookieSecure]::description,
		'Will you use HTTPS only to access Software Risk Manager?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, set the Secure attribute because I plan to use HTTPS.',
			'No, do not set the Secure attribute because I plan to use HTTP.', -1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.authCookieSecure = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[bool]CanRun(){
		return -not $this.config.authCookieSecure
	}

	[void]Reset(){
		$this.config.authCookieSecure = $false
	}
}
