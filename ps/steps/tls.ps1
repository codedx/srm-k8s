class UseTlsOption : Step {

	static [string] hidden $description = @'
Specify whether you want to use CertificateSigningRequests to enable TLS between
communications that support TLS. This requires a certificate signing capability
running on your cluster.

Note: The Scan Farm feature's scan and storage services do not support TLS.
'@

	UseTlsOption([Config] $config) : base(
		[UseTlsOption].Name, 
		$config,
		'Configure TLS',
		[UseTlsOption]::description,
		'Protect component communications using TLS (where available)?') {}

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, I want to use TLS (where available)',
			'No, I don''t want to use TLS to secure component communications', 1)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$this.config.webServicePortNumber = 9090
		$this.config.skipTls = ([YesNoQuestion]$question).choice -eq 1

		if (-not $this.config.skipTLS) {
			$this.config.webServicePortNumber = 9443

			$valuesTlsFilePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../chart/values/values-tls.yaml'))
			$this.config.SetNote($this.GetType().Name, "- Before you run the Helm Prep Script, you must do the prework in the comments at the top of '$valuesTlsFilePath'")
		}
		return $true
	}

	[void]Reset(){
		$this.config.skipTls = $false
		$this.config.webServicePortNumber = 9090
		$this.config.RemoveNote($this.GetType().Name)
	}
}


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
		return -not $this.config.skipTLS
	}
}

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
		return -not $this.config.skipTLS
	}
}