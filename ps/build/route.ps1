function Get-FormattedCertificate($certPath, $indentSize) {
	[string]::join("`n$([string]::new(' ', $indentSize))", (Get-Content $certPath))
}

function New-OpenShiftRouteConfig($config) {

	$routeTlsEnabled = $config.routeTlsType -eq [RouteTlsType]::ExternalCertificate

	@"
openshift:
  routes:
    enabled: true
    host: $($config.routeHostname)
    tls:
      enabled: $($routeTlsEnabled ? 'true' : 'false')
"@ | Out-File (Get-OpenShiftRouteValuesPath $config)

	if (-not $config.skipScanFarm) {

		# Scan Farm cache service uses a self-signed CA, which must be trusted by the related Route
		New-OpenShiftRouteScanFarmTlsDestinationConfig $config
	}

	if ($config.IsTlsConfigHandlingCertificates()) {

		# Route must have reencrypt termination for the web service to be accessible
		New-OpenShiftRouteWebTlsDestinationConfig $config
	}

	if ($routeTlsEnabled) {
		New-OpenShiftRouteTlsConfig $config
	}
}

function New-OpenShiftRouteTlsConfig($config) {

	@"
openshift:
  routes:
    tls:
      certificate: |-
        $(Get-FormattedCertificate $config.routeTlsCertificatePath 8)
      key: |-
        $(Get-FormattedCertificate $config.routeTlsKeyPath 8)
"@ | Out-File (Get-OpenShiftRouteTlsValuesPath $config)

	if ($config.routeTlsUseCACertificate) {
			@"
openshift:
  routes:
    tls:
      caCertificate: |-
        $(Get-FormattedCertificate $config.routeTlsCACertificatePath 8)
"@ | Out-File (Get-OpenShiftRouteCaTlsValuesPath $config)
	}
}

function New-OpenShiftRouteWebTlsDestinationConfig($config) {

	@"
openshift:
  routes:
    tls:
      destination:
        webCaCertificate: |-
          $(Get-FormattedCertificate $config.clusterCertificateAuthorityCertPath 10)
"@ | Out-File (Get-OpenShiftRouteWebTlsValuesPath $config)
}

function New-OpenShiftRouteScanFarmTlsDestinationConfig($config) {

  # The Scan Farm CA is generated at deployment time, so the following
  # script fetches the certificate by starting the same job that runs at
  # deployment time.

@"

Write-Host "Creating private registry resource..."
kubectl -n $($config.namespace) apply -f '$(Get-RegistryK8sPath $config)'

`$resourceName = 'scan-services-ca-gen'
`$jobYaml = @"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: scan-services-ca-gen
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: scan-services-ca-gen
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: scan-services-ca-gen
subjects:
  - kind: ServiceAccount
    name: scan-services-ca-gen
roleRef:
  kind: Role
  name: scan-services-ca-gen
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: scan-services-ca-manifest
data:
  manifest.yml: |
    globalConfig:
      keyLength: 2048
      validityInDays: 365
    certificates:
      - storage:
          k8s:
            secret:
              name: $($config.releaseName)-ca-x509
        request:
          configuration:
            commonName: CNC Certificate Authority
            organization:
              - 00000000-0000-0000-0000-000000000000
            country:
              - US
          ipAddresses:
          san:
          - "ca"
          type:
            - ca
            - server
            - client
---
apiVersion: batch/v1
kind: Job
metadata:
  name: scan-services-ca-gen
spec:
  template:
    metadata:
      name: scan-services-ca-gen
    spec:
      restartPolicy: Never
      containers:
      - command:
        - /cnc-common-infra
        - generate
        - --manifest
        - /manifests/manifest.yml
        - --file-type
        - yaml
        env:
        - name: CNC_KUBERNETES_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        - name: OPERATION
          value: certgen
        image: $($config.GetRegistryAndPrefix())/common-infra:2025.6.2
        imagePullPolicy: Always
        name: cnc-common-infra
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - mountPath: /manifests
          name: manifests
      serviceAccountName: scan-services-ca-gen
      imagePullSecrets:
      - name: reg
      volumes:
      - configMap:
          name: scan-services-ca-manifest
        name: manifests
`"@

Write-Host "Creating job `$resourceName..."
`$jobYaml | kubectl -n $($config.namespace) apply -f -

Write-Host "Waiting for job `$resourceName to complete..."
kubectl -n $($config.namespace) wait --for=condition=complete --timeout=600s "job/`$resourceName"

`$caSecretName = '$($config.releaseName)-ca-x509'

Write-Host "Fetching CA cert from `$caSecretName..."
`$scanfarmCaCert = kubectl -n $($config.namespace) get secret srm-ca-x509 -o=go-template='{{ index .data "tls.crt" | base64decode }}'

@`"
openshift:
  routes:
    tls:
      destination:
        scanfarmCaCertificate: |-
          `$([string]::join("``n          ", `$scanfarmCaCert))
`"@ | Out-File '$(Get-OpenShiftRouteScanFarmTlsValuesPath $config)'

Write-Host "Removing job `$resourceName..."
`$jobYaml | kubectl -n $($config.namespace) delete -f -

"@ | Out-File (Get-OpenShiftRouteScanFarmTlsScriptPath $config)
}