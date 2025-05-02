[ConfigAttribute(("componentTlsType","skipTls","webServicePortNumber"))]
class UseTlsOption : Step {

	static [string] hidden $description = @'
Specify whether you want to enable TLS between SRM components that support TLS.

Using Istio Service Mesh in Ambient mode with mTLS enabled is the recommended
way to secure communications between SRM components. You can alternatively use
CertificateSigningRequests, provided by cert-manager kube-csr or a similiar
component, or you can use cert-manager Certificate resources if cert-manager
is already installed on your cluster. Refer to the TLS pre-work sections of the
Software Risk Manager Deployment Guide for more information.

Note: The Scan Farm feature's scan and storage services do not support TLS via
CertificateSigningRequests or cert-manager's Certificate CRD resource. If you
want to use TLS with those services, you must use Istio service mesh's Ambient
mode.
'@

	UseTlsOption([Config] $config) : base(
		[UseTlsOption].Name, 
		$config,
		'Configure TLS',
		[UseTlsOption]::description,
		'Specify your TLS configuration for SRM components') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&None', 'Do not use TLS between SRM components'),
			[tuple]::create('&Istio Ambient', 'Use Istio Ambient mode with mTLS enabled for SRM component TLS'),
			[tuple]::create('&Cert-Manager Certificates', 'Use cert-manager Certificate resources for SRM component TLS'),
			[tuple]::create('&K8s CSR', 'Use K8s Certificate Signing Requests for SRM component TLS')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {

		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.componentTlsType = [ComponentTlsType]::None }
			1 { $this.config.componentTlsType = [ComponentTlsType]::IstioAmbient }
			2 { $this.config.componentTlsType = [ComponentTlsType]::CertManagerCertificates }
			3 { $this.config.componentTlsType = [ComponentTlsType]::K8sCSR }
		}
		$this.config.skipTls = $this.config.componentTlsType -eq [ComponentTlsType]::None
		$this.config.webServicePortNumber = [ComponentTlsType]::CertManagerCertificates,[ComponentTlsType]::K8sCSR -contains $this.config.componentTlsType ? 9443 : 9090
		return $true
	}

	[void]Reset(){
		$this.config.skipTls = $false
		$this.config.componentTlsType = [ComponentTlsType]::None
		$this.config.webServicePortNumber = 9090
	}
}


[ConfigAttribute(("clusterCertificateAuthorityCertPath"))]
class CertsCAPath : Step {

	static [string] hidden $description = @'
Specify a path to the CA (PEM format) associated with the Kubernetes 
Certificates API (certificates.k8s.io API) signer(s) you plan to use.

For instructions on how to use cert-manager as a signer for Certificate 
Signing Request Kubernetes resources, refer to the comments in this file:

/path/to/values-tls.yaml
'@

	CertsCAPath([Config] $config) : base(
		[CertsCAPath].Name, 
		$config,
		'Kubernetes Certificates API CA',
		[CertsCAPath]::description.Replace('/path/to/values-tls.yaml', $([io.path]::GetFullPath((Join-Path $PSScriptRoot '../../chart/values/values-tls.yaml')))),
		'Enter the file path for your Kubernetes CA cert') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object CertificateFileQuestion($prompt, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.clusterCertificateAuthorityCertPath = ([CertificateFileQuestion]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.clusterCertificateAuthorityCertPath = ''
	}

	[bool]CanRun() {
		return $this.config.IsTlsConfigHandlingCertificates()
	}
}

[ConfigAttribute(("csrSignerName"))]
class SignerName : Step {

	static [string] hidden $description = @'
Specify the signerName for the CertificateSigningRequests (CSR) required for 
components in the SRM namespace.
'@

	SignerName([Config] $config) : base(
		[SignerName].Name, 
		$config,
		'SRM CSR Signer',
		[SignerName]::description,
		'Enter the SRM components CSR signerName') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.csrSignerName = ([Question]$question).GetResponse([SignerName]::default)
		return $true
	}

	[void]Reset(){
		$this.config.csrSignerName = ''
	}

	[bool]CanRun() {
		return $this.config.IsUsingK8sCertificateSigningRequest()
	}
}

[ConfigAttribute(("certManagerIssuerName"))]
class CertificateIssuerName : Step {

	static [string] hidden $description = @'
Specify the name of your existing cert-manager issuer resource.
'@

	CertificateIssuerName([Config] $config) : base(
		[CertificateIssuerName].Name, 
		$config,
		'Cert-Manager Issuer Name',
		[CertificateIssuerName]::description,
		'Enter the name of your cert-manager issuer') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.certManagerIssuerName = ([Question]$question).GetResponse([SignerName]::default)
		return $true
	}

	[void]Reset(){
		$this.config.certManagerIssuerName = ''
	}

	[bool]CanRun() {
		return $this.config.IsUsingCertManagerCertificates()
	}
}

[ConfigAttribute(("certManagerIssuerType"))]
class CertificateIssuerType : Step {

	static [string] hidden $description = @'
Specify the type of your cert-manager issuer resource. The ClusterIssuer
type is cluster-scoped and can be used by all namespaces. The Issuer type
is namespace-scoped and can only be used by the namespace in which it is
created.
'@

	CertificateIssuerType([Config] $config) : base(
		[CertificateIssuerType].Name, 
		$config,
		'Cert-Manager Issuer Type',
		[CertificateIssuerType]::description,
		'Enter your type of cert-manager issuer') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object MultipleChoiceQuestion($prompt, @(
			[tuple]::create('&ClusterIssuer', 'The cert-manager issuer is of type ClusterIssuer'),
			[tuple]::create('&Issuer', 'The cert-manager issuer is of type Issuer')), 0)
	}

	[bool]HandleResponse([IQuestion] $question) {

		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.certManagerIssuerType = [CertManagerIssuerType]::ClusterIssuer }
			1 { $this.config.certManagerIssuerType = [CertManagerIssuerType]::Issuer }
		}
		return $true
	}

	[void]Reset(){
		$this.config.certManagerIssuerType = [CertManagerIssuerType]::None
	}

	[bool]CanRun() {
		return $this.config.IsUsingCertManagerCertificates()
	}
}
