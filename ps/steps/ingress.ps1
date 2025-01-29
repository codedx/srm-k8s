class IngressKind : Step {

	static [string] hidden $description = @'
Specify how you will access SRM running on your cluster.
'@

	static [string] hidden $openshiftDescription = @'


The Helm Prep Wizard does not include support for creating OpenShift 
routes. If you plan to use routes, configure your routes after installing SRM.

Note: You can select an ingress option initially to create an ingress 
resource from which you can pattern a path-based route definition.
'@

	IngressKind([Config] $config) : base(
		[IngressKind].Name, 
		$config,
		'Ingress Type',
		[IngressKind]::description,
		'What type of ingress do you want to use?') {}

	[string]GetMessage() {

		$message = [IngressKind]::description

		if ($this.config.k8sProvider -eq [ProviderType]::OpenShift) {
			$message += [IngressKind]::openshiftDescription
		}
		return $message
	}

	[IQuestion]MakeQuestion([string] $prompt) {

		$choices = @(
			[tuple]::create('Ingress-NGINX (Community)', 'Create an ingress resource for use with an NGINX Community ingress controller (kubernetes/ingress-nginx repo) you install separately')
			[tuple]::create('Other Ingress', 'Create an ingress resource for use with another ingress controller you install separately')
		)

		if ($this.config.skipScanFarm) {

			$choices += [tuple]::create('ClusterIP Service', 'Configure the SRM Kubernetes service as a ClusterIP service type (use port-forward or something else to access SRM)')
			$choices += [tuple]::create('NodePort Service', 'Configure the SRM Kubernetes service as a NodePort service type')
			$choices += [tuple]::create('LoadBalancer Service', 'Configure the SRM Kubernetes service as a LoadBalancer service type')

			if ($this.config.k8sProvider -eq [ProviderType]::Eks) {
				$choices += [tuple]::create('Classic ELB (HTTPS)', 'Use AWS Classic Load Balancer with Certificate Manager')
				$choices += [tuple]::create('Network ELB (HTTPS)', 'Use AWS Network Load Balancer with Certificate Manager')
				$choices += [tuple]::create('Internal Classic ELB (HTTPS)', 'Use Internal AWS Classic Load Balancer')
			}
		}

		return new-object MultipleChoiceQuestion($prompt, $choices, 0)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$this.config.skipIngressEnabled = $true
		$this.config.webServiceType = 'ClusterIP'

		$authCookieSecure = $false
		switch (([MultipleChoiceQuestion]$question).choice) {
			0 { $this.config.ingressType = [IngressType]::NginxIngressCommunity; $this.config.skipIngressEnabled = $false; }
			1 { $this.config.ingressType = [IngressType]::OtherIngress; $this.config.skipIngressEnabled = $false; }
			2 { $this.config.ingressType = [IngressType]::ClusterIP }
			3 { $this.config.ingressType = [IngressType]::NodePort; $this.config.webServiceType = 'NodePort' }
			4 { $this.config.ingressType = [IngressType]::LoadBalancer; $this.config.webServiceType = 'LoadBalancer' }
			5 { $this.config.ingressType = [IngressType]::ClassicElb; $this.config.webServiceType = 'LoadBalancer'; $authCookieSecure = $true }
			6 { $this.config.ingressType = [IngressType]::NetworkElb; $this.config.webServiceType = 'LoadBalancer'; $authCookieSecure = $true }
			7 { $this.config.ingressType = [IngressType]::InternalClassicElb; $this.config.webServiceType = 'LoadBalancer'; $authCookieSecure = $true }
		}
		$this.config.authCookieSecure = $authCookieSecure

		$this.config.ingressAnnotations = @()
		if ($this.config.IsElbIngress()) {
			# always use port 443 for AWS ELB provisioning (if skipTls is false, service can be accessed w/o ELB via HTTP on 443)
			$this.config.webServicePortNumber = 443
		}

		if ($this.config.IsIngress()) {

			if ($this.config.ingressType -eq [IngressType]::NginxIngressCommunity -and -not $this.config.skipTls) {

				# retain two default annotations
				$this.config.SetIngressAnnotation('nginx.ingress.kubernetes.io/proxy-read-timeout', '3600')
				$this.config.SetIngressAnnotation('nginx.ingress.kubernetes.io/proxy-body-size', '0')

				# add HTTPS annotation
				$this.config.SetIngressAnnotation('nginx.ingress.kubernetes.io/backend-protocol', 'HTTPS')
			}
			elseif ($this.config.ingressType -eq [IngressType]::OtherIngress) {

				$tlsSvcs = @()
				if (-not $this.config.skipTls) {
					$tlsSvcs += $this.config.GetWebServiceName()
				}
				if (-not $this.config.skipScanFarm) {
					$tlsSvcs += $this.config.GetCacheServiceName()
				}
				if ($tlsSvcs.length -gt 0) {
					$this.config.SetNote($this.GetType().Name, "- You will likely need to add an ingress annotation for communicating with these HTTPS service(s): $tlsSvcs")
				}
			}
		}

		return $true
	}

	[void]Reset(){
		$this.config.skipIngressEnabled = $false
		$this.config.ingressAnnotations = @()
		$this.config.webServiceType = ''
		$this.config.ingressType = [IngressType]::ClusterIP
		$this.config.authCookieSecure = $false

		$this.config.webServicePortNumber = 9090
		if (-not $this.config.skipTls) {
			$this.config.webServicePortNumber = 9443
		}
	}
}

class IngressClassName : Step {

	static [string] hidden $description = @'
Specify the ingress class name for your ingress controller. For example,
'nginx' is the default NGINX Community ingress class name.

Note: Your ingress controller must support multiple ingress
resources referencing the same hostname.
'@

	IngressClassName([Config] $config) : base(
		[IngressClassName].Name, 
		$config,
		'Ingress Class Name',
		[IngressClassName]::description,
		'Enter ingress class name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.ingressClassName = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.ingressClassName = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipIngressEnabled
	}
}

class IngressTLS : Step {

	static [string] hidden $description = @'
Specify how you will configure your ingress.

Using the cert-manager option (e.g., Let's Encrypt ) requires an 
existing cert-manager deployment with a ClusterIssuer resource
(cluster-wide scope) or Issuer resource in the SRM namespace. 
For more details, refer to this URL:

https://cert-manager.io/docs/configuration/

To use the External Kubernetes TLS Secret option, you must create 
a Kubernetes TLS Secret resource in the SRM namespace. For more 
details, refer to this URL:

https://kubernetes.io/docs/concepts/services-networking/ingress/#tls

Use of an unsecured HTTP ingress is not recommended. Its use should
be limited to dev/test-related deployments.
'@

	IngressTLS([Config] $config) : base(
		[IngressTLS].Name, 
		$config,
		'Ingress TLS',
		[IngressTLS]::description,
		'How will you secure your ingress?') {}

	[IQuestion]MakeQuestion([string] $prompt) {

		$choices = @(
			[tuple]::create('Unsecured HTTP (dev/test only)', 'Access SRM using HTTP (not secure)')
			[tuple]::create('Cert-Manager (Issuer)', 'Access SRM using HTTPS and an cert-manager issuer like Let''s Encrypt'),
			[tuple]::create('Cert-Manager (ClusterIssuer)', 'Access SRM using HTTPS and an cert-manager issuer like Let''s Encrypt'),
			[tuple]::create('External Kubernetes TLS Secret', 'Access SRM using HTTPS and an existing Kubernetes TLS secret')
		)

		return new-object MultipleChoiceQuestion($prompt, $choices, 3)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$authCookieSecure = $true
		$choice = ([MultipleChoiceQuestion]$question).choice

		switch ($choice) {
			0 { $this.config.ingressTlsType = [IngressTlsType]::None; $authCookieSecure = $false }
			1 { $this.config.ingressTlsType = [IngressTlsType]::CertManagerIssuer }
			2 { $this.config.ingressTlsType = [IngressTlsType]::CertManagerClusterIssuer }
			3 { $this.config.ingressTlsType = [IngressTlsType]::ExternalSecret }
		}
		$this.config.authCookieSecure = $authCookieSecure

		return $true
	}

	[void]Reset(){
		$this.config.ingressTlsType = [IngressTlsType]::None
		$this.config.authCookieSecure = $false
	}

	[bool]CanRun() {
		return $this.config.IsIngress()
	}
}

class IngressTLSSecretName : Step {

	static [string] hidden $description = @'
Specify the name of an existing Kubernetes TLS Secret resource to 
reference in the TLS section of your ingress.

For more details, refer to this URL:
https://kubernetes.io/docs/concepts/services-networking/ingress/#tls

The command to create the Kubernetes TLS Secret resource will look like this:
kubectl -n cdx-namespace create secret tls name --cert=cert.pem --key=key.pem

Note: Your Kubernetes TLS Secret resource must already exist in the
SRM namespace. Otherwise, the ingress controller may use a 
fake/invalid certificate. 
'@

	IngressTLSSecretName([Config] $config) : base(
		[IngressTLSSecretName].Name,
		$config,
		'Ingress TLS Secret Name',
		[IngressTLSSecretName]::description,
		'Enter the name of your existing Kubernetes TLS Secret name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.ingressTlsSecretName = ([Question]$question).response
		$this.config.SetNote($this.GetType().Name, "- Your ingress configuration requires an existing TLS secret named '$($this.config.ingressTlsSecretName)'")
		return $true
	}

	[void]Reset(){
		$this.config.ingressTlsSecretName = ''
		$this.config.RemoveNote($this.GetType().Name)
	}

	[bool]CanRun() {
		return $this.config.ingressTlsType -eq [IngressTlsType]::ExternalSecret
	}
}

class CertManagerIssuer : Step {

	static [string] hidden $description = @'
Specify the name of the cert-manager issuer you plan to use.

Note: Your cert-manager issuer must already exist.
'@

	static [string] hidden $issuerAnnotationKey = 'cert-manager.io/issuer'
	static [string] hidden $clusterIssuerAnnotationKey = 'cert-manager.io/cluster-issuer'

	CertManagerIssuer([Config] $config) : base(
		[CertManagerIssuer].Name, 
		$config,
		'Cert-Manager Issuer',
		[CertManagerIssuer]::description,
		'Enter the name of your cert-manager issuer') {}

	[bool]HandleResponse([IQuestion] $question) {

		$annotationKey = [CertManagerIssuer]::issuerAnnotationKey
		if ($this.config.ingressTlsType -eq [IngressTlsType]::CertManagerClusterIssuer) {
			$annotationKey = [CertManagerIssuer]::clusterIssuerAnnotationKey
		}

		$annotationValue = ([Question]$question).response
		$this.config.SetIngressAnnotation($annotationKey, $annotationValue)

		$ingressTlsName = $this.config.GetFullNameWithSuffix("-web-ingress")
		$this.config.ingressTlsSecretName = $ingressTlsName
		$this.config.SetNote($this.GetType().Name, "- Your ingress configuration requires an existing cert-manager deployment with issuer '$annotationKey`: $annotationValue'")
		return $true
	}

	[void]Reset(){
		$this.config.ingressTlsSecretName = ''
		$this.config.RemoveIngressAnnotation([CertManagerIssuer]::issuerAnnotationKey)
		$this.config.RemoveIngressAnnotation([CertManagerIssuer]::clusterIssuerAnnotationKey)
		$this.config.RemoveNote($this.GetType().Name)
	}

	[bool]CanRun() {
		return $this.config.IsIngressCertManagerTls()
	}
}

class IngressCertificateArn : Step {

	static [string] hidden $description = @'
Specify the Amazon Resource Name (ARN) for the certificate you want to use 
with the SRM EKS service. You can create a new certificate using the
AWS Certificates console.
'@

	IngressCertificateArn([Config] $config) : base(
		[IngressCertificateArn].Name, 
		$config,
		'AWS Certificate ARN',
		[IngressCertificateArn]::description,
		'Enter your certificate ARN') {}

	[bool]HandleResponse([IQuestion] $question) {
		
		$certArn = ([Question]$question).response

		$isNetworkElb = $this.config.ingressType -eq [IngressType]::NetworkElb

		$backendProtocol = 'http'
		if (-not $this.config.skipTls) {
			$backendProtocol = $isNetworkElb ? 'ssl' : 'https'
		}
		$this.config.SetWebServiceAnnotation('service.beta.kubernetes.io/aws-load-balancer-backend-protocol', $backendProtocol)
		$this.config.SetWebServiceAnnotation('service.beta.kubernetes.io/aws-load-balancer-ssl-ports', 'https')
		$this.config.SetWebServiceAnnotation('service.beta.kubernetes.io/aws-load-balancer-ssl-cert', $certArn)
		if ($isNetworkElb) {
			$this.config.SetWebServiceAnnotation('service.beta.kubernetes.io/aws-load-balancer-type', 'nlb')
		}
		if ($this.config.IsElbInternalIngress()) {
			$this.config.SetWebServiceAnnotation('service.beta.kubernetes.io/aws-load-balancer-internal', 'true')
		}

		return $true
	}

	[void]Reset(){
		$this.config.webServiceAnnotations = @()
	}

	[bool]CanRun() {
		return $this.config.IsElbIngress()
	}
}

class IngressHostname : Step {

	static [string] hidden $description = @'
Specify the DNS name to associate with the SRM web application. This can 
be the hostname in lowercase letters when running on minikube or the server 
name of a host you will access over the network using a DNS registration.
'@

	IngressHostname([Config] $config) : base(
		[IngressHostname].Name, 
		$config,
		'SRM DNS Name',
		[IngressHostname]::description,
		'Enter DNS name') {}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.ingressHostname = ([Question]$question).response
		return $true
	}

	[void]Reset(){
		$this.config.ingressHostname = ''
	}

	[bool]CanRun() {
		return -not $this.config.skipIngressEnabled
	}
}
