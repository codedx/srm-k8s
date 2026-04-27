[ConfigAttribute(("gatewayExternalEnabled","ingressType"))]
class GatewayExternal : Step {

	static [string] hidden $description = @'
Specify whether you want to attach to a pre-existing shared Gateway resource
or have the wizard create a dedicated Gateway resource for SRM.

Using an external (shared) Gateway is common when a single Gateway controller
manages traffic for multiple applications in your cluster. You will need to
provide the name, namespace, and optional section name of the shared Gateway.

If you choose to create a dedicated Gateway, the wizard will create a Gateway
resource in the SRM namespace using the class name you specify.
'@

	GatewayExternal([Config] $config) : base(
		[GatewayExternal].Name,
		$config,
		'Gateway Type',
		[GatewayExternal]::description,
		'How do you want to configure the Gateway?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$choices = @(
			[tuple]::create('Create a dedicated Gateway', 'The wizard will create a Gateway resource in the SRM namespace')
			[tuple]::create('Attach to a shared (external) Gateway', 'Attach the SRM HTTPRoute to a pre-existing Gateway resource')
		)
		return new-object MultipleChoiceQuestion($prompt, $choices, 0)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayExternalEnabled = ([MultipleChoiceQuestion]$question).choice -eq 1
		return $true
	}

	[void]Reset() {
		$this.config.gatewayExternalEnabled = $false
	}

	[bool]CanRun() {
		return $this.config.IsGateway()
	}
}

[ConfigAttribute(("gatewayExternalName","ingressType"))]
class GatewayExternalName : Step {

	static [string] hidden $description = @'
Specify the name of the pre-existing shared Gateway resource that the SRM
HTTPRoute should attach to.
'@

	GatewayExternalName([Config] $config) : base(
		[GatewayExternalName].Name,
		$config,
		'Shared Gateway Name',
		[GatewayExternalName]::description,
		'Enter the name of the shared Gateway resource') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayExternalName = ([Question]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.gatewayExternalName = 'gateway'
	}

	[bool]CanRun() {
		return $this.config.IsGateway() -and $this.config.gatewayExternalEnabled
	}
}

[ConfigAttribute(("gatewayExternalNamespace","ingressType"))]
class GatewayExternalNamespace : Step {

	static [string] hidden $description = @'
Specify the namespace where the pre-existing shared Gateway resource lives.
'@

	GatewayExternalNamespace([Config] $config) : base(
		[GatewayExternalNamespace].Name,
		$config,
		'Shared Gateway Namespace',
		[GatewayExternalNamespace]::description,
		'Enter the namespace of the shared Gateway resource') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayExternalNamespace = ([Question]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.gatewayExternalNamespace = 'nginx-gateway'
	}

	[bool]CanRun() {
		return $this.config.IsGateway() -and $this.config.gatewayExternalEnabled
	}
}

[ConfigAttribute(("gatewayExternalSectionName","ingressType"))]
class GatewayExternalSectionName : Step {

	static [string] hidden $description = @'
Optionally specify the listener section name on the shared Gateway to attach
to (e.g. "https"). Leave blank to attach to all listeners on the Gateway.
'@

	GatewayExternalSectionName([Config] $config) : base(
		[GatewayExternalSectionName].Name,
		$config,
		'Shared Gateway Section Name',
		[GatewayExternalSectionName]::description,
		'Enter the listener section name (leave blank to attach to all listeners)') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayExternalSectionName = ([Question]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.gatewayExternalSectionName = ''
	}

	[bool]CanRun() {
		return $this.config.IsGateway() -and $this.config.gatewayExternalEnabled
	}
}

[ConfigAttribute(("gatewayClassName","ingressType"))]
class GatewayClassName : Step {

	static [string] hidden $description = @'
Specify the GatewayClass name for the Gateway resource. This must match the
name of a GatewayClass installed in your cluster.

For example:
  "nginx"  - NGINX Gateway Fabric (default)
  "istio"  - Istio Gateway Controller
'@

	GatewayClassName([Config] $config) : base(
		[GatewayClassName].Name,
		$config,
		'Gateway Class Name',
		[GatewayClassName]::description,
		'Enter the GatewayClass name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayClassName = ([Question]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.gatewayClassName = 'nginx'
	}

	[bool]CanRun() {
		return $this.config.IsGateway() -and -not $this.config.gatewayExternalEnabled
	}
}

[ConfigAttribute(("authCookieSecure","gatewayTlsType","ingressType"))]
class GatewayTLS : Step {

	static [string] hidden $description = @'
Specify how you will configure TLS for the Gateway listener.

Using the cert-manager option requires an existing cert-manager deployment
with a ClusterIssuer (cluster-wide scope) or Issuer resource in the SRM
namespace. For more details, refer to:

https://cert-manager.io/docs/configuration/

To use the External Kubernetes TLS Secret option, you must create a
Kubernetes TLS Secret resource in the Gateway namespace. For more details,
refer to:

https://kubernetes.io/docs/concepts/services-networking/ingress/#tls

Use of an unsecured HTTP gateway is not recommended. Its use should be
limited to dev/test-related deployments.
'@

	GatewayTLS([Config] $config) : base(
		[GatewayTLS].Name,
		$config,
		'Gateway TLS',
		[GatewayTLS]::description,
		'How will you secure your Gateway?') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		$choices = @(
			[tuple]::create('Unsecured HTTP (dev/test only)', 'Access SRM using HTTP (not secure)')
			[tuple]::create('Cert-Manager (Issuer)', 'Access SRM using HTTPS with a cert-manager Issuer like Let''s Encrypt')
			[tuple]::create('Cert-Manager (ClusterIssuer)', 'Access SRM using HTTPS with a cert-manager ClusterIssuer like Let''s Encrypt')
			[tuple]::create('External Kubernetes TLS Secret', 'Access SRM using HTTPS with an existing Kubernetes TLS secret')
		)
		return new-object MultipleChoiceQuestion($prompt, $choices, 3)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$authCookieSecure = $true
		$choice = ([MultipleChoiceQuestion]$question).choice

		switch ($choice) {
			0 { $this.config.gatewayTlsType = [GatewayTlsType]::None; $authCookieSecure = $false }
			1 { $this.config.gatewayTlsType = [GatewayTlsType]::CertManagerIssuer; $this.config.gatewayCertManagerEnabled = $true; $this.config.gatewayCertManagerIssuerKind = 'Issuer' }
			2 { $this.config.gatewayTlsType = [GatewayTlsType]::CertManagerClusterIssuer; $this.config.gatewayCertManagerEnabled = $true; $this.config.gatewayCertManagerIssuerKind = 'ClusterIssuer' }
			3 { $this.config.gatewayTlsType = [GatewayTlsType]::ExternalSecret }
		}
		$this.config.authCookieSecure = $authCookieSecure

		return $true
	}

	[void]Reset() {
		$this.config.gatewayTlsType = [GatewayTlsType]::None
		$this.config.gatewayCertManagerEnabled = $false
		$this.config.gatewayCertManagerIssuerKind = 'ClusterIssuer'
		$this.config.authCookieSecure = $false
	}

	[bool]CanRun() {
		return $this.config.IsGateway()
	}
}

[ConfigAttribute(("gatewayCertManagerEnabled","gatewayCertManagerIssuerKind","gatewayCertManagerIssuerName","gatewayTlsSecretName","ingressType"))]
class GatewayCertManagerIssuer : Step {

	static [string] hidden $description = @'
Specify the name of the cert-manager issuer you plan to use.

Note: Your cert-manager issuer must already exist.
'@

	GatewayCertManagerIssuer([Config] $config) : base(
		[GatewayCertManagerIssuer].Name,
		$config,
		'Gateway Cert-Manager Issuer',
		[GatewayCertManagerIssuer]::description,
		'Enter the name of your cert-manager issuer') {}

	[bool]HandleResponse([IQuestion] $question) {

		$issuerName = ([Question]$question).response
		$this.config.gatewayCertManagerIssuerName = $issuerName

		$secretName = $this.config.GetFullNameWithSuffix('-gateway-tls')
		$this.config.gatewayTlsSecretName = $secretName

		$this.config.SetNote($this.GetType().Name, "- Your Gateway configuration requires an existing cert-manager deployment with issuer '$($this.config.gatewayCertManagerIssuerKind): $issuerName'")
		return $true
	}

	[void]Reset() {
		$this.config.gatewayCertManagerIssuerName = ''
		$this.config.gatewayTlsSecretName = ''
		$this.config.RemoveNote($this.GetType().Name)
	}

	[bool]CanRun() {
		return $this.config.IsGatewayCertManagerTls()
	}
}

[ConfigAttribute(("gatewayTlsSecretName","gatewayTlsType","ingressType"))]
class GatewayTLSSecretName : Step {

	static [string] hidden $description = @'
Specify the name of an existing Kubernetes TLS Secret resource to reference
in the TLS section of your Gateway listener. The secret must exist in the
Gateway namespace.

The command to create the Kubernetes TLS Secret resource will look like this:
kubectl -n gateway-namespace create secret tls name --cert=cert.pem --key=key.pem
'@

	GatewayTLSSecretName([Config] $config) : base(
		[GatewayTLSSecretName].Name,
		$config,
		'Gateway TLS Secret Name',
		[GatewayTLSSecretName]::description,
		'Enter the name of your existing Kubernetes TLS Secret') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayTlsSecretName = ([Question]$question).response
		$this.config.SetNote($this.GetType().Name, "- Your Gateway configuration requires an existing TLS secret named '$($this.config.gatewayTlsSecretName)'")
		return $true
	}

	[void]Reset() {
		$this.config.gatewayTlsSecretName = ''
		$this.config.RemoveNote($this.GetType().Name)
	}

	[bool]CanRun() {
		return $this.config.gatewayTlsType -eq [GatewayTlsType]::ExternalSecret
	}
}

[ConfigAttribute(("gatewayHostname","ingressType"))]
class GatewayHostname : Step {

	static [string] hidden $description = @'
Specify the DNS name to associate with the SRM web application via the
Gateway and HTTPRoute resources. This should be the fully qualified domain
name (FQDN) that clients will use to access SRM.
'@

	GatewayHostname([Config] $config) : base(
		[GatewayHostname].Name,
		$config,
		'SRM Gateway DNS Name',
		[GatewayHostname]::description,
		'Enter DNS name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.gatewayHostname = ([Question]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.gatewayHostname = ''
	}

	[bool]CanRun() {
		return $this.config.IsGateway()
	}
}
