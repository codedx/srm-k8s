[ConfigAttribute(("ingressType","routeHostname"))]
class RouteHostname : Step {

	static [string] hidden $description = @'
Specify the DNS name to associate with the SRM web application. This can 
a name that resolves locally on your host or the server name you will
access over the network using a DNS registration.
'@

	RouteHostname([Config] $config) : base(
		[RouteHostname].Name, 
		$config,
		'Route Hostname',
		[RouteHostname]::description,
		'Enter DNS name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.routeHostname = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.routeHostname = ''
	}

	[bool]CanRun() {
		return $this.config.ingressType -eq [IngressType]::Route
	}
}

[ConfigAttribute(("authCookieSecure","ingressType","routeTlsType"))]
class RouteTLS : Step {

	static [string] hidden $description = @'
Specify how you will configure your route(s).

Use of an unsecured HTTP route is not recommended; its use should
be limited to dev/test-related deployments.

Securing your route(s) with HTTPS requires using a certificate
that you provide.

Note: If you opt for an unsecured Route for development or testing
purposes and are using the Scan Farm feature or have configured
component TLS with certificates you provide, OpenShift will use its
own certificate.
'@

	RouteTLS([Config] $config) : base(
		[RouteTLS].Name, 
		$config,
		'Route TLS',
		[RouteTLS]::description,
		'How will you secure your route(s)?') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$choices = @(
			[tuple]::create('Unsecured HTTP (dev/test only)', 'Access via HTTP (not secure)')
			[tuple]::create('HTTPS External Certificate', 'Access via HTTPS using a certificate you provide')
		)

		return new-object MultipleChoiceQuestion($prompt, $choices, 1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$authCookieSecure = $false
		$choice = ([MultipleChoiceQuestion]$question).choice

		switch ($choice) {
			0 { $this.config.routeTlsType = [RouteTlsType]::None }
			1 { $this.config.routeTlsType = [RouteTlsType]::ExternalCertificate; $authCookieSecure = $true }
		}
		$this.config.authCookieSecure = $authCookieSecure

		return $true
	}

	[void]Reset(){
		$this.config.routeTlsType = [RouteTlsType]::None
		$this.config.authCookieSecure = $false
	}

	[bool]CanRun() {
		return $this.config.ingressType -eq [IngressType]::Route
	}
}

[ConfigAttribute(("routeTlsType","routeTlsUseCACertificate"))]
class RouteTlsUseCACertificate : Step {

	static [string] hidden $description = @'
Your Route configuration can optionally include a CA certificate to
complete the certificate chain.
'@

	RouteTlsUseCACertificate([Config] $config) : base(
		[RouteTlsUseCACertificate].Name, 
		$config,
		'Route TLS CA Certificate Option',
		[RouteTlsUseCACertificate]::description,
		'Do you want to include a CA certificate?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to include a CA certificate in my Route.',
			'No, I do not want to include a CA certificate in my Route.', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.routeTlsUseCACertificate = ([YesNoQuestion]$question).choice -eq 0
		return $true
	}

	[void]Reset(){
		$this.config.routeTlsUseCACertificate = $false
	}

	[bool]CanRun() {
		return $this.config.routeTlsType -eq [RouteTlsType]::ExternalCertificate
	}
}

[ConfigAttribute(("routeTlsCACertificatePath","routeTlsType","routeTlsUseCACertificate"))]
class RouteTlsCACertificatePath : Step {

	static [string] hidden $description = @'
Specify a file path to a PEM-formatted file containing the CA certificate
for your Route configuration.
'@

	RouteTlsCACertificatePath([Config] $config) : base(
		[RouteTlsCACertificatePath].Name, 
		$config,
		'Route TLS CA Certificate',
		[RouteTlsCACertificatePath]::description,
		'Enter the file path for your Route CA certificate') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.routeTlsCACertificatePath = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.routeTlsCACertificatePath = ''
	}

	[bool]CanRun() {
		return $this.config.routeTlsType -eq [RouteTlsType]::ExternalCertificate -and $this.config.routeTlsUseCACertificate
	}
}

[ConfigAttribute(("routeTlsCertificatePath","routeTlsType"))]
class RouteTlsCertificatePath : Step {

	static [string] hidden $description = @'
Specify a file path to a PEM-formatted file containing the certificate
for your Route configuration.
'@

	RouteTlsCertificatePath([Config] $config) : base(
		[RouteTlsCertificatePath].Name, 
		$config,
		'Route TLS Certificate',
		[RouteTlsCertificatePath]::description,
		'Enter the file path for your Route certificate') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.routeTlsCertificatePath = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.routeTlsCertificatePath = ''
	}

	[bool]CanRun() {
		return $this.config.routeTlsType -eq [RouteTlsType]::ExternalCertificate
	}
}

[ConfigAttribute(("routeTlsKeyPath","routeTlsType"))]
class RouteTlsKeyPath : Step {

	static [string] hidden $description = @'
Specify a file path containing the private key for your Route
configuration.
'@

	RouteTlsKeyPath([Config] $config) : base(
		[RouteTlsKeyPath].Name, 
		$config,
		'Route TLS Key',
		[RouteTlsKeyPath]::description,
		'Enter the file path for your Route key') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object PathQuestion($prompt,	$false, $false)
	}
	
	[bool]HandleResponse([IQuestion] $question) {
		$this.config.routeTlsKeyPath = ([PathQuestion]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.routeTlsKeyPath = ''
	}

	[bool]CanRun() {
		return $this.config.routeTlsType -eq [RouteTlsType]::ExternalCertificate
	}
}