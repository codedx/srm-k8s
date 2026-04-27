function New-ServiceConfig($config) {

  $portName = 'http'
  if ($config.IsElbIngress()) {
    # force https to ensure correct AWS ELB generation
    $portName = 'https'
  }

	@"
web:
  service:
    type: $($config.webServiceType)
    annotations: $(ConvertTo-YamlMap $config.GetWebServiceAnnotations())
    port: $($config.webServicePortNumber)
    port_name: '$portName'
"@ | Out-File (Get-WebServiceValuesPath $config)
}

function New-IngressTlsConfig($config) {

	@"
ingress:
  tls:
    - secretName: $($config.ingressTlsSecretName)
      hosts:
        - $($config.ingressHostname)
"@ | Out-File (Get-IngressTlsValuesPath $config)
}

function New-IngressAnnotationsConfig($config) {

  @"
ingress:
  annotations:
    web: $(ConvertTo-YamlMap $config.GetIngressAnnotations())
"@ | Out-File (Get-IngressAnnotationsValuesPath $config)
}

function New-IngressConfig($config) {

	@"
ingress:
  enabled: true
  className: $($config.ingressClassName)
  hosts:
    - host: $($config.ingressHostname)
"@ | Out-File (Get-IngressValuesPath $config)

	if ($config.ingressTlsSecretName) {
		New-IngressTlsConfig $config
	}

  if ($config.ingressAnnotations.length -gt 0) {
    New-IngressAnnotationsConfig $config
  }
}

function New-GatewayConfig($config) {

	$tlsEnabled = $config.IsGatewayTls()

	@"
gateway:
  enabled: true
  hostname: $($config.gatewayHostname)
  className: $($config.gatewayClassName)
  external:
    enabled: $($config.gatewayExternalEnabled ? 'true' : 'false')
    name: $($config.gatewayExternalName)
    namespace: $($config.gatewayExternalNamespace)
    sectionName: $($config.gatewayExternalSectionName)
  tls:
    enabled: $($tlsEnabled ? 'true' : 'false')
    secretName: $($config.gatewayTlsSecretName)
    certManager:
      enabled: $($config.gatewayCertManagerEnabled ? 'true' : 'false')
      issuerRef:
        name: $($config.gatewayCertManagerIssuerName)
        kind: $($config.gatewayCertManagerIssuerKind)
"@ | Out-File (Get-GatewayValuesPath $config)
}