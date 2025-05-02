function Get-CertsK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'cacerts.k8s.yaml'
}

function Get-CertsK8sValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'cacerts.values.yaml'
}

function Get-CertsPath($config) {
	Join-Path $config.GetTempWorkDir() 'cacerts'
}

function Get-DatabasePropsK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'db-props.k8s.yaml'
}

function Get-DatabaseMariaDbK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'db-mariadb.k8s.yaml'
}

function Get-DatabasePropsPath($config) {
	Join-Path $config.GetTempWorkDir() 'db.props'
}

function Get-DatabaseCredentialValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-cred.values.yaml'
}

function Get-DatabaseRdsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-rds.values.yaml'
}

function Get-DatabaseReplicationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-replication.values.yaml'
}

function Get-DatabaseDockerImageLocationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-docker-image-location.values.yaml'
}

function Get-DatabaseDockerImageVersionValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-docker-image-version.values.yaml'
}

function Get-SamlIdPK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'web-saml-idp.k8s.yaml'
}

function Get-SamlPropsPath($config) {
	Join-Path $config.GetTempWorkDir() 'web-saml.props'
}

function Get-SamlSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'web-saml-secret.k8s.yaml'
}

function Get-SamlValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-saml.values.yaml'
}

function Get-StorageDockerImageLocationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-docker-image-location.values.yaml'
}

function Get-StorageDockerImageVersionValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-docker-image-version.values.yaml'
}

function Get-ScanFarmDockerImageLocationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-docker-image-location.values.yaml'
}

function Get-ToDockerImageLocationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-docker-image-location.values.yaml'
}

function Get-ToDockerImageVersionValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-docker-image-version.values.yaml'
}

function Get-WebDockerImageLocationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-docker-image-location.values.yaml'
}

function Get-WebDockerImageVersionValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-docker-image-version.values.yaml'
}

function Get-WorkflowDockerImageVersionValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'workflow-docker-image-version.values.yaml'
}

function Get-NetworkPolicyValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'netpol.values.yaml'
}

function Get-NetworkPolicyEgressValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'netpol.egress.values.yaml'
}

function Get-OpenShiftValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'openshift.values.yaml'
}

function Get-RegistryK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'reg.k8s.yaml'
}

function Get-RegistryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'reg.values.yaml'
}

function Get-ToWorkflowStorageSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'wf-storage-secret.k8s.yaml'
}

function Get-ToWorkflowStoragePath($config) {
	Join-Path $config.GetValuesWorkDir()  'to.workflow-storage.values.yaml'
}

function Get-ToExternalWorkflowStorageCertK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'wf-storage-cert.k8s.yaml'
}

function Get-ToExternalWorkflowStorageCertSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'wf-storage-cert-secret.k8s.yaml'
}

function Get-ToExternalWorkflowStoragePath($config) {
	Join-Path $config.GetValuesWorkDir()  'to.external-workflow-storage.values.yaml'
}

function Get-ToExternalWorkflowStorageServiceAccountPath($config) {
	Join-Path $config.GetValuesWorkDir()  'to.external-workflow-storage-sa.values.yaml'
}

function Get-ToExternalCertWorkflowStoragePath($config) {
	Join-Path $config.GetValuesWorkDir()  'to.external-cert-workflow-storage.values.yaml'
}

function Get-ToKeyPropsPath($config) {
	Join-Path $config.GetTempWorkDir() 'to-key.props'
}

function Get-ToCredentialK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'to-cred.k8s.yaml'
}

function Get-ToKeyK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'to-key.k8s.yaml'
}

function Get-ToConfigValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-config.values.yaml'
}

function Get-ToConfigMinIOValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-config-minio.values.yaml'
}

function Get-ToConfigPriorityClassValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-config-pc.values.yaml'
}

function Get-ToConfigWorkflowNamespaceValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-config-wf-ns.values.yaml'
}

function Get-ToCredentialValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-cred.values.yaml'
}

function Get-WebK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'web.k8s.yaml'
}

function Get-WebValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web.values.yaml'
}

function Get-WebCPUValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-cpu.values.yaml'
}

function Get-MasterDatabaseCPUValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-cpu.values.yaml'
}

function Get-SubordinateDatabaseCPUValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-cpu.values.yaml'
}

function Get-ToCPUValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-cpu.values.yaml'
}

function Get-StorageCPUValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-cpu.values.yaml'
}

function Get-WorkflowCPUValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'workflow-cpu.values.yaml'
}

function Get-WebMemoryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-memory.values.yaml'
}

function Get-MasterDatabaseMemoryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-memory.values.yaml'
}

function Get-SubordinateDatabaseMemoryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-memory.values.yaml'
}

function Get-ToMemoryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-memory.values.yaml'
}

function Get-StorageMemoryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-memory.values.yaml'
}

function Get-WorkflowMemoryValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'workflow-memory.values.yaml'
}

function Get-WebEphemeralStorageValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-ephemeral-storage.values.yaml'
}

function Get-MasterDatabaseEphemeralStorageValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-ephemeral-storage.values.yaml'
}

function Get-SubordinateDatabaseEphemeralStorageValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-ephemeral-storage.values.yaml'
}

function Get-ToEphemeralStorageValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-ephemeral-storage.values.yaml'
}

function Get-StorageEphemeralStorageValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-ephemeral-storage.values.yaml'
}

function Get-WorkflowEphemeralStorageValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'workflow-ephemeral-storage.values.yaml'
}

function Get-WebVolumeSizeValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-volume-size.values.yaml'
}

function Get-MasterDatabaseVolumeSizeValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-volume-size.values.yaml'
}

function Get-SubordinateDatabaseVolumeSizeValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-volume-size.values.yaml'
}

function Get-StorageVolumeSizeValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-volume-size.values.yaml'
}

function Get-WebVolumeStorageClassValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-volume-class.values.yaml'
}

function Get-MasterDatabaseVolumeStorageClassValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-volume-class.values.yaml'
}

function Get-SubordinateDatabaseVolumeStorageClassValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-volume-class.values.yaml'
}

function Get-StorageVolumeStorageClassValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-volume-class.values.yaml'
}

function Get-WebNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-node.values.yaml'
}

function Get-MasterDatabaseNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-node.values.yaml'
}

function Get-SubordinateDatabaseNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-node.values.yaml'
}

function Get-ToNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-node.values.yaml'
}

function Get-StorageNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-node.values.yaml'
}

function Get-WorkflowNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'workflow-node.values.yaml'
}

function Get-ToolsNodeSelectorValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'tools-node.values.yaml'
}

function Get-WebTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-toleration.values.yaml'
}

function Get-MasterDatabaseTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-toleration.values.yaml'
}

function Get-SubordinateDatabaseTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'db-subordinate-toleration.values.yaml'
}

function Get-ToTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'to-toleration.values.yaml'
}

function Get-StorageTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'storage-toleration.values.yaml'
}

function Get-WorkflowTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'workflow-toleration.values.yaml'
}

function Get-ToolsTolerationValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'tools-toleration.values.yaml'
}

function Get-WebServiceValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-svc.values.yaml'
}

function Get-WebServiceAccountValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'web-svc-acct.values.yaml'
}

function Get-IngressValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'ingress.values.yaml'
}

function Get-IngressAnnotationsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'ingress.annotations.values.yaml'
}

function Get-IngressTlsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'ingress-tls.values.yaml'
}

function Get-ScanFarmLicenseSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-lic.k8s.yaml'
}

function Get-ScanFarmLicenseValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-lic.values.yaml'
}

function Get-ScanFarmLicenseTypeValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-lic-type.values.yaml'
}

function Get-LicenseSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'srm-lic.k8s.yaml'
}

function Get-LicenseSecretValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'srm-lic.values.yaml'
}

function Get-ScanFarmValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm.values.yaml'
}

function Get-ScanFarmTrustStoresValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-trust-stores.values.yaml'
}

function Get-ScanFarmInternalUrlValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-storage-internal.values.yaml'
}

function Get-ScanFarmStorageExternalProxiedUrlValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-storage-proxy.values.yaml'
}

function Get-ScanFarmStorageExternalUrlValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-storage-external.values.yaml'
}

function Get-ScanFarmDatabaseSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-database.k8s.yaml'
}

function Get-ScanFarmDatabaseCertK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-database-tls.k8s.yaml'
}

function Get-ScanFarmDatabaseValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-database.values.yaml'
}

function Get-ScanFarmDatabaseTlsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-db-tls.values.yaml'
}

function Get-ScanFarmCacheValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-cache.values.yaml'
}

function Get-ScanFarmCacheAuthSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-cache-auth.k8s.yaml'
}

function Get-ScanFarmCacheAuthValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-cache-auth.values.yaml'
}

function Get-ScanFarmCacheTlsK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-cache-tls.k8s.yaml'
}

function Get-ScanFarmCacheTlsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-cache-tls.values.yaml'
}

function Get-ScanFarmMinIORootK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-minio-storage.k8s.yaml'
}

function Get-ScanFarmAwsS3K8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-aws-storage.k8s.yaml'
}

function Get-ScanFarmGcsK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-gcs-storage.k8s.yaml'
}

function Get-ScanFarmAzureK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-azure-storage.k8s.yaml'
}

function Get-ScanFarmMinIOValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-minio-storage.values.yaml'
}

function Get-ScanFarmMinIOTlsK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'scan-farm-minio-storage-tls.k8s.yaml'
}

function Get-ScanFarmMinIOTlsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-minio-storage-tls.values.yaml'
}

function Get-ScanFarmAwsS3ValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-aws-storage.values.yaml'
}

function Get-ScanFarmGcsValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-gcs-storage.values.yaml'
}

function Get-ScanFarmAzureValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'scan-farm-azure-storage.values.yaml'
}

function Get-SigRepoSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'sig-repo-secret.k8s.yaml'
}

function Get-SizingValuesPath($config) {
	Join-Path $config.GetValuesWorkDir() 'sizing.values.yaml'
}

function Get-ClusterCaCertCfgMapK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'cluster-ca-cfgmap.k8s.yaml'
}

function Get-ClusterCaCertSecretK8sPath($config) {
	Join-Path $config.GetK8sWorkDir() 'cluster-ca-secret.k8s.yaml'
}

function Get-K8sCsrScriptPath($config) {
	Join-Path $config.GetScriptsWorkDir() 'csr-cert-script.ps1'
}

function Get-CertManagerCertificateK8sPath($config) {
	Join-Path $config.GetValuesWorkDir() 'cert-manager-certificate.k8s.yaml'
}