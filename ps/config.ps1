enum ProviderType {
	Minikube
	Aks
	Eks
	OpenShift
	Other
}

enum IngressType {
	NginxIngress
	NginxIngressCommunity
	OtherIngress
	ClusterIP
	NodePort
	LoadBalancer
	ClassicElb
	NetworkElb
	InternalClassicElb
}

enum IngressTlsType {
	None
	CertManagerIssuer
	CertManagerClusterIssuer
	ExternalSecret
}

enum ScanFarmLicenseType {
	None
	Sast
	Sca
	All
}

enum ScanFarmStorageType {
	AwsS3
	MinIO
	Gcs
	Azure
}

enum SystemSize {
	Unspecified
	ExtraSmall
	Small
	Medium
	Large
	ExtraLarge
}

enum WorkflowStorageType {
	OnCluster
	AccessKey
	AwsIAM
}

enum ScanFarmLicenseFormatType {
	Legacy
	CombinedKeygen
}

class Config {

	static [int]   $kubeApiTargetPortDefault = 443
	static [int]   $toolServiceReplicasDefault = 0     # new default to support system size override when > 0
	static [int]   $volumeSizeGiBDefault = 0           # new default to support system size override when > 0
	static [int]   $externalDatabasePortDefault = 3306

	static [string]   $thisVersion = "1.7"

	static [string[]] $protectedFields = @(
		'repoUsername',
		'repoPwd',
		'scanFarmDatabaseUser',
		'scanFarmDatabasePwd',
		'scanFarmRedisPwd',
		'scanFarmS3AccessKey',
		'scanFarmS3SecretKey',
		'scanFarmS3ServiceAccountName',
		'scanFarmGcsSvcAccountKey',
		'scanFarmAzureStorageAccountKey',
		'scanFarmAzureClientId',
		'scanFarmAzureClientSecret',
		'scanFarmMinIORootUsername',
		'scanFarmMinIORootPwd',
		'mariadbRootPwd',
		'mariadbReplicatorPwd',
		'srmDatabaseUserPwd',
		'adminPwd',
		'toolServiceApiKey',
		'minioAdminPwd',
		'externalDatabaseUser',
		'externalDatabasePwd',
		'externalWorkflowStorageUsername',
		'externalWorkflowStoragePwd',
		'samlKeystorePwd',
		'samlPrivateKeyPwd',
		'dockerRegistryUser',
		'dockerRegistryPwd',
		'caCertsFilePwd'
	)

	[string]       $configVersion

	[string]       $namespace                                # formerly namespaceCodeDx
	[string]       $releaseName                              # formerly releaseNameCodeDx

	[string]       $workDir

	[string]       $srmLicenseFile
	[string]       $scanFarmSastLicenseFile
	[string]       $scanFarmScaLicenseFile
	[string]       $scanFarmCombinedLicenseFile
	[string]       $scanFarmLicenseFormatType

	[string]       $repoUsername
	[string]       $repoPwd

	[string]       $scanFarmDatabaseHost
	[string]       $scanFarmDatabasePort
	[string]       $scanFarmDatabaseUser
	[string]       $scanFarmDatabasePwd
	[string]       $scanFarmDatabaseSslMode
	[string]       $scanFarmDatabaseServerCert
	[string]       $scanFarmScanDatabaseCatalog
	[string]       $scanFarmStorageDatabaseCatalog

	[string]       $scanFarmRedisHost
	[string]       $scanFarmRedisPort
	[string]       $scanFarmRedisDatabase
	[bool]         $scanFarmRedisUseAuth
	[string]       $scanFarmRedisPwd
	[bool]         $scanFarmRedisSecure
	[bool]         $scanFarmRedisVerifyHostname
	[string]       $scanFarmRedisServerCert

	[string]       $scanFarmStorageType
	[string]       $scanFarmStorageBucketName
	[string]       $scanFarmCacheBucketName

	[bool]         $scanFarmS3UseServiceAccountName
	[string]       $scanFarmS3AccessKey
	[string]       $scanFarmS3SecretKey
	[string]       $scanFarmS3ServiceAccountName
	[string]       $scanFarmS3Region

	[string]       $scanFarmGcsProjectName
	[string]       $scanFarmGcsSvcAccountKey

	[string]       $scanFarmAzureStorageAccount
	[string]       $scanFarmAzureStorageAccountKey
	[string]       $scanFarmAzureSubscriptionId
	[string]       $scanFarmAzureTenantId
	[string]       $scanFarmAzureResourceGroup
	[string]       $scanFarmAzureEndpoint
	[string]       $scanFarmAzureClientId
	[string]       $scanFarmAzureClientSecret

	[string]       $scanFarmMinIOHostname
	[string]       $scanFarmMinIOPort
	[string]       $scanFarmMinIORootUsername
	[string]       $scanFarmMinIORootPwd
	[bool]         $scanFarmMinIOSecure
	[bool]         $scanFarmMinIOVerifyHostname
	[string]       $scanFarmMinIOServerCert

	[bool]         $scanFarmStorageHasInClusterUrl
	[string]       $scanFarmStorageInClusterUrl
	[bool]         $scanFarmStorageIsProxied
	[string]       $scanFarmStorageContextPath
	[string]       $scanFarmStorageExternalUrl

	[bool]         $useGeneratedPwds
	[string]       $mariadbRootPwd
	[string]       $mariadbReplicatorPwd
	[string]       $srmDatabaseUserPwd                       # formerly codedxDatabaseUserPwd
	[string]       $adminPwd                                 # formerly codedxAdminPwd
	[string]       $toolServiceApiKey
	[string]       $minioAdminPwd

	[string]       $k8sProvider
	[string]       $kubeApiTargetPort

	[string]       $clusterCertificateAuthorityCertPath
	[string]       $csrSignerName                            # formerly csrSignerNameCodeDx

	[bool]         $createSCCs

	[ScanFarmLicenseType] $scanFarmType

	[bool]         $skipDatabase
	[bool]         $useTriageAssistant                       # deprecated
	[bool]         $skipScanFarm
	[bool]         $skipToolOrchestration
	[bool]         $skipMinIO
	[bool]         $skipNetworkPolicies
	[bool]         $skipTls

	[string]       $workflowStorageType
	[string]       $serviceAccountToolService
	[string]       $serviceAccountWorkflow

	[int]          $toolServiceReplicas

	[int]          $dbSlaveReplicaCount

	[string]       $externalDatabaseHost
	[int]          $externalDatabasePort
	[string]       $externalDatabaseName
	[string]       $externalDatabaseUser
	[string]       $externalDatabasePwd
	[bool]         $externalDatabaseSkipTls
	[bool]         $externalDatabaseTrustCert
	[string]       $externalDatabaseServerCert

	[string]       $externalWorkflowStorageEndpoint
	[bool]         $externalWorkflowStorageEndpointSecure
	[string]       $externalWorkflowStorageUsername
	[string]       $externalWorkflowStoragePwd
	[string]       $externalWorkflowStorageBucketName
	[bool]         $externalWorkflowStorageTrustCert
	[string]       $externalWorkflowStorageCertChainPath

	[bool]         $addExtraCertificates
	[string[]]     $extraTrustedCaCertPaths                  # formely extraCodeDxTrustedCaCertPaths

	[string]       $webServiceType                           # formerly serviceTypeCodeDx
	[string]       $webServicePortNumber                     # formerly codeDxServicePortNumber/codeDxTlsServicePortNumber
	[KeyValue[]]   $webServiceAnnotations = @()              # formerly serviceAnnotationsCodeDx

	[bool]         $skipIngressEnabled
	[string]       $ingressType
	[string]       $ingressClassName                         # formerly ingressClassNameCodeDx
	[KeyValue[]]   $ingressAnnotations = @()                 # formerly ingressAnnotationsCodeDx
	[string]       $ingressHostname                          # formerly codeDxDnsName
	[string]       $ingressTlsSecretName                     # formerly ingressTlsSecretNameCodeDx
	[string]       $ingressTlsType

	[bool]         $useSaml
	[bool]         $useLdap
	[string]       $samlHostBasePath                         # formerly samlHostBasePathOverride
	[string]       $samlIdentityProviderMetadataPath
	[string]       $samlAppName
	[string]       $samlKeystorePwd
	[string]       $samlPrivateKeyPwd

	[bool]         $skipDockerRegistryCredential             # formely skipPrivateDockerRegistry
	[string]       $dockerImagePullSecretName
	[string]       $dockerRegistry
	[string]       $dockerRegistryUser
	[string]       $dockerRegistryPwd

	[bool]         $useDefaultDockerImages
	[string]       $imageVersionWeb
	[string]       $imageVersionMariaDB
	[string]       $imageVersionTo
	[string]       $imageVersionMinio
	[string]       $imageVersionWorkflow

	[bool]         $useDockerRedirection
	[bool]         $useDockerRepositoryPrefix
	[string]       $dockerRepositoryPrefix                   # formerly redirectDockerHubReferencesTo

	[bool]         $useDefaultCACerts
	[string]       $caCertsFilePath
	[string]       $caCertsFilePwd

	[bool]         $useCPUDefaults
	[string]       $webCPUReservation                        # formerly codeDxCPUReservation
	[string]       $dbMasterCPUReservation
	[string]       $dbSlaveCPUReservation
	[string]       $toolServiceCPUReservation
	[string]       $minioCPUReservation
	[string]       $workflowCPUReservation

	[bool]         $useMemoryDefaults
	[string]       $webMemoryReservation                     # formerly codeDxMemoryReservation
	[string]       $dbMasterMemoryReservation
	[string]       $dbSlaveMemoryReservation
	[string]       $toolServiceMemoryReservation
	[string]       $minioMemoryReservation
	[string]       $workflowMemoryReservation

	[bool]         $useEphemeralStorageDefaults
	[string]       $webEphemeralStorageReservation           # formerly codeDxEphemeralStorageReservation
	[string]       $dbMasterEphemeralStorageReservation
	[string]       $dbSlaveEphemeralStorageReservation
	[string]       $toolServiceEphemeralStorageReservation
	[string]       $minioEphemeralStorageReservation
	[string]       $workflowEphemeralStorageReservation

	[bool]         $useVolumeSizeDefaults
	[int]          $webVolumeSizeGiB                         # formerly codeDxVolumeSizeGiB
	[int]          $dbVolumeSizeGiB
	[int]          $dbSlaveVolumeSizeGiB
	[int]          $dbSlaveBackupVolumeSizeGiB
	[int]          $minioVolumeSizeGiB
	[string]       $storageClassName

	[string]       $systemSize

	[bool]         $useNodeSelectors
	[KeyValue]     $webNodeSelector                          # formerly codeDxNodeSelector
	[KeyValue]     $masterDatabaseNodeSelector
	[KeyValue]     $subordinateDatabaseNodeSelector
	[KeyValue]     $toolServiceNodeSelector
	[KeyValue]     $minioNodeSelector
	[KeyValue]     $workflowControllerNodeSelector
	[KeyValue]     $toolNodeSelector

	[bool]         $useTolerations
	[KeyValue]     $webNoScheduleExecuteToleration           # formerly codeDxNoScheduleExecuteToleration
	[KeyValue]     $masterDatabaseNoScheduleExecuteToleration
	[KeyValue]     $subordinateDatabaseNoScheduleExecuteToleration
	[KeyValue]     $toolServiceNoScheduleExecuteToleration
	[KeyValue]     $minioNoScheduleExecuteToleration
	[KeyValue]     $workflowControllerNoScheduleExecuteToleration
	[KeyValue]     $toolNoScheduleExecuteToleration

	[bool]         $authCookieSecure

	[KeyValue[]]  $notes = @()

	[KeyValue[]]  $salts
	[bool]        $isLocked

	[string] $scanFarmScaApiUrlOverride # used for dev/test/support only

	Config() {
		$this.configVersion = [Config]::thisVersion
		$this.toolServiceReplicas = [Config]::toolServiceReplicasDefault
		$this.kubeApiTargetPort = [Config]::kubeApiTargetPortDefault
		$this.webVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.dbVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.dbSlaveVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.minioVolumeSizeGiB = [Config]::volumeSizeGiBDefault
		$this.externalDatabasePort = [Config]::externalDatabasePortDefault
		$this.skipDockerRegistryCredential = $true
		$this.useDefaultDockerImages = $true
		$this.skipTls = $true
		$this.webServicePortNumber = 9090

		# v1.1 fields
		$this.salts = @()
		$this.isLocked = $false
		# v1.2 fields
		$this.scanFarmStorageIsProxied = $true       # < v1.2 assumed proxy
		$this.scanFarmStorageContextPath = 'upload'  # < v1.2 assumed upload
		$this.scanFarmStorageExternalUrl = ''        # redundantly initialized for readability
		# v1.3 fields
		$this.systemSize = [SystemSize]::Unspecified # < 1.3 set CPU and memory independently (unspecified for backward compatibility)
		$this.useTriageAssistant = $true             # minimum resource size accounts for Triage Assistant
		# v1.4 fields
		$this.workflowStorageType = [WorkflowStorageType]::OnCluster # < 1.4 skipMinIO ? [WorkflowStorageType]::AccessKey : [WorkflowStorageType]::OnCluster
		$this.serviceAccountToolService = ''
		$this.serviceAccountWorkflow = ''
		# v1.5 fields
		$this.authCookieSecure = $false
		# v1.6 no new fields, only field renames
		# v1.7 fields
		$this.scanFarmCombinedLicenseFile = ''
		$this.scanFarmLicenseFormatType = [ScanFarmLicenseFormatType]::Legacy

		# Note: the restore-version.ps1 script should account for any config.json format changes
	}

	static [PSObject] RenameJsonField($json, $oldField, $newField) {

		# convert JSON object to a hashtable
		$json = $json | ConvertTo-Json | ConvertFrom-Json -AsHashtable
		$hasOldField = $null -ne $json.$oldField

		if ($hasOldField) {
			$json.$newField = $json.$oldField
			$json.Remove($oldField)

			# update related salt to avoid an unlock problem
			if ($json.salts.length -gt 0) {
				0..($json.salts.length-1) | ForEach-Object {
					if ($json.salts[$_].key -eq $oldField) {
						$json.salts[$_].key = $newField
					}
				}
			}
		}

		# convert hashtable back to a custom PSObject
		return $json | ConvertTo-Json | ConvertFrom-Json
	}

	static [PSObject] RemoveJsonField($json, $fieldName) {

		# convert JSON object to a hashtable
		$json = $json | ConvertTo-Json | ConvertFrom-Json -AsHashtable
		$hasField = $null -ne $json.$fieldName
	
		if ($hasField) {
			$json.Remove($fieldName)
	
			# drop an outdated salt
			$json.salts = $json.salts | Where-Object { $_.key -ne $fieldName }
		}
	
		# convert hashtable back to a custom PSObject
		return $json | ConvertTo-Json | ConvertFrom-Json
	}

	static [Config] FromJsonFile($configJsonFile) {

		$configJson = Get-Content $configJsonFile | ConvertFrom-Json

		$configJsonVersion = '1.0'
		if ($null -ne $configJson.configVersion) {
			$configJsonVersion = $configJson.configVersion
		}

		$version = new-object Management.Automation.SemanticVersion($configJsonVersion)
		$currentVersion = new-object Management.Automation.SemanticVersion([Config]::thisVersion)

		if ($version -gt $currentVersion) {
			throw "Unable to handle config version: $($configJson.configVersion)"
		}

		# file version 1.6 replaces sigRepoUsername with repoUsername and sigRepoPwd with repoPwd
		$oneDotSixVersion = new-object Management.Automation.SemanticVersion('1.6')
		if ($version -lt $currentVersion -and $version -lt $oneDotSixVersion) {
			$configJson = [Config]::RenameJsonField($configJson, 'sigRepoUsername', 'repoUsername')
			$configJson = [Config]::RenameJsonField($configJson, 'sigRepoPwd', 'repoPwd')
		}

		$config = [Config]$configJson

		$v1Dot4 = new-object Management.Automation.SemanticVersion('1.4')
		$version = new-object Management.Automation.SemanticVersion($config.configVersion)

		if ($version -lt $v1Dot4) {
			# workflow storage type did not exist before v1.4
			if ($config.skipMinIO) {
				$config.workflowStorageType = [WorkflowStorageType]::AccessKey
			}
		}

		# override config version obtained on file import
		$config.configVersion = [Config]::thisVersion
		return $config
	}

	[bool]IsElbIngress() {
		return $this.ingressType -eq [IngressType]::ClassicElb -or `
			$this.ingressType -eq [IngressType]::NetworkElb -or `
			$this.ingressType -eq [IngressType]::InternalClassicElb
	}

	[bool]IsElbInternalIngress() {
		return $this.ingressType -eq [IngressType]::InternalClassicElb
	}

	[bool]IsIngress() {
		return $this.ingressType -eq [IngressType]::NginxIngressCommunity -or `
			$this.ingressType -eq [IngressType]::OtherIngress
	}

	[bool]IsIngressTls() {
		return $this.ingressTlsType -eq [IngressTlsType]::ExternalSecret -or `
			$this.ingressTlsType -eq [IngressTlsType]::CertManagerIssuer -or `
			$this.ingressTlsType -eq [IngressTlsType]::CertManagerClusterIssuer
	}

	[bool]IsIngressCertManagerTls() {
		return $this.ingressTlsType -eq [IngressTlsType]::CertManagerIssuer -or `
			$this.ingressTlsType -eq [IngressTlsType]::CertManagerClusterIssuer
	}

	[string]GetFullName() {
		$fullName = Get-HelmChartFullnameEquals $this.releaseName 'srm'
		$fullName = $fullName.substring(0, [math]::min($fullName.length, 63)).TrimEnd('-')
		return $fullName
	}

	[string]GetFullNameWithSuffix([string] $suffix) {
		$suffixLength = $suffix.Length
		$fullNameWithSuffix = $this.GetFullName() + $suffix
		$fullNameWithSuffix = $fullNameWithSuffix.substring(0, [math]::min($fullNameWithSuffix.length, 63-$suffixLength)).TrimEnd('-')
		return $fullNameWithSuffix
	}

	[string]GetWebServiceName() {
		return $this.GetFullNameWithSuffix("-web")
	}

	[string]GetScanServiceName() {
		return "$($this.releaseName)-scan-service"
	}

	[string]GetStorageServiceName() {
		return "$($this.releaseName)-storage-service"
	}

	[string]GetCacheServiceName() {
		return "$($this.releaseName)-cache-service"
	}

	SetNote([string] $key, [string] $value) {
		$this.notes = $this.GetAllExcept($this.notes, $key) + [KeyValue]::new($key, $value)
	}

	RemoveNote([string] $key) {
		$this.notes = $this.GetAllExcept($this.notes, $key)
	}

	[Hashtable]GetIngressAnnotations() {
		return $this.BuildTable($this.ingressAnnotations)
	}

	SetIngressAnnotation([string] $key, [string] $value) {
		$this.ingressAnnotations = $this.GetAllExcept($this.ingressAnnotations, $key) + [KeyValue]::new($key, $value)
	}

	RemoveIngressAnnotation([string] $key) {
		$this.ingressAnnotations = $this.GetAllExcept($this.ingressAnnotations, $key)
	}

	[Hashtable]GetWebServiceAnnotations() {
		return $this.BuildTable($this.webServiceAnnotations)
	}

	SetWebServiceAnnotation([string] $key, [string] $value) {
		$this.webServiceAnnotations = $this.GetAllExcept($this.webServiceAnnotations, $key) + [KeyValue]::new($key, $value)
	}

	[string]GetWorkDir() {
		return Resolve-Path -LiteralPath $this.workDir | Select-Object -ExpandProperty 'Path'
	}

	[string]GetValuesWorkDir() {
		return Join-Path ($this.GetWorkDir()) 'chart-values'
	}

	[string]GetValuesCombinedWorkDir() {
		return Join-Path ($this.GetWorkDir()) 'chart-values-combined'
	}

	[string]GetK8sWorkDir() {
		return Join-Path ($this.GetWorkDir()) 'chart-resources'
	}

	[string]GetTempWorkDir() {
		return Join-Path ($this.GetWorkDir()) 'chart-temp'
	}

	[KeyValue[]]GetAllExcept([KeyValue[]] $keyValues, [string] $key) {
		return $keyValues | Where-Object {
			$_.key -ne $key
		}
	}

	[Hashtable]BuildTable([KeyValue[]] $keyValues) {
		$table = @{}
		if ($null -ne $keyValues) {
			$keyValues | ForEach-Object {
				$table[$_.key] = $_.value
			}
		}
		return $table
	}

	[bool] ShouldLock() {

		$protectedFieldsWithValues = [Config]::protectedFields | Where-Object {
			$value = $this.$_
			-not [string]::IsNullOrEmpty($value)
		}
		return $protectedFieldsWithValues.Length -gt 0
	}

	[void] Lock([string] $configPwd) {

		if ($this.isLocked) {
			throw 'Unable to lock config because it''s already locked'
		}

		$this.salts = @()

		try {
			[Config]::protectedFields | ForEach-Object {
				
				$value = $this.$_
				if (-not [string]::IsNullOrEmpty($value)) {
					$protectedValue = Protect-StringValue $configPwd $value
					$this.salts += [KeyValue]::New($_, $protectedValue[0])
					$this.$_ = $protectedValue[1]
				}
			}
			$this.isLocked = $true
			$this.SetNote($this.GetType().Name, '- Specify your config.json password using either the helm-prep.ps1 script''s -configFilePwd parameter, the HELM_PREP_CONFIGFILEPWD environment variable, or by entering your password when prompted.')
		} catch {
			throw "Unable to lock config file. The error was: $_"
		}
	}

	[void] Unlock([string] $configPwd) {

		if (-not $this.isLocked) {
			throw 'Unable to unlock config because it''s already unlocked'
		}

		try {
			[Config]::protectedFields | ForEach-Object {

				$field = $_
				if (-not [string]::IsNullOrEmpty($this.$_)) {
					$salt = $this.salts | Where-Object { $_.key -eq $field } | ForEach-Object { $_.value }
					# unprotect this value if it was previously protected
					if ($null -ne $salt) {
						$this.$_ = Unprotect-StringValue $configPwd $salt $this.$_
					}
				}
			}
			$this.isLocked = $false
			$this.salts = @()
			$this.RemoveNote($this.GetType().Name)
		} catch {
			throw "Unable to unlock config file. Is the password correct? The error was: $_"
		}
	}

	[bool] IsSystemSizeSpecified() {
		return -not ([string]::IsNullOrEmpty($this.systemSize) -or $this.systemSize -eq [SystemSize]::Unspecified)
	}
}

class ConfigAttribute : System.Attribute {
    [string[]]$values

    ConfigAttribute([string[]]$values) {
        $this.values = $values
    }
}