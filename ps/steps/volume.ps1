[ConfigAttribute(("useVolumeSizeDefaults"))]
class DefaultVolumeSize : Step {

	static [string] hidden $description = @'
Specify whether you want to use the recommended volume sizes displayed 
below. You can specify each volume size individually by responding with 
the No option.
'@

	static [string] hidden $subordinateDatabaseDescription = @'
Note: Subordinate database containers use two volumes, the main database 
volume and a volume to store backup files. The default volume size for the 
subordinate database specified here applies to *each* volume. For example, 
specifying 64 means creating two 64 GiB volumes.
'@

	DefaultVolumeSize([Config] $config) : base(
		[DefaultVolumeSize].Name, 
		$config,
		'Volume Sizes',
		[DefaultVolumeSize]::description,
		'Use default volume sizes?') { }

	[IQuestion] MakeQuestion([string] $prompt) {
		return new-object YesNoQuestion($prompt,
			'Yes, do not specify sizes for each volume',
			'No, specify a size for each volume', 0)
	}

	[bool]HandleResponse([IQuestion] $question) {

		$applyDefaults = ([YesNoQuestion]$question).choice -eq 0
		if ($applyDefaults) {
			$this.GetSteps() | ForEach-Object {
				$_.ApplyDefault()
			}
		}
		$this.config.useVolumeSizeDefaults = $applyDefaults
		return $true
	}

	[void]Reset() {
		$this.config.useVolumeSizeDefaults = $false
	}

	[Step[]] GetSteps() {

		$steps = @()
		[WebVolumeSize],[MasterDatabaseVolumeSize],[SubordinateDatabaseVolumeSize],[SubordinateDatabaseBackupVolumeSize],[MinIOVolumeSize] | ForEach-Object {
			$step = new-object -type $_ -args $this.config
			if ($step.CanRun()) {
				$steps += $step
			}
		}
		return $steps
	}

	[string]GetMessage() {

		$message = [DefaultVolumeSize]::description
		$message += "`n`nHere are the defaults:`n`n"
		$steps = $this.GetSteps()
		$steps | ForEach-Object {
			$default = $_.GetDefault()
			if ('' -ne $default) {
				$message += "    {0}: {1}`n" -f (([VolumeSizeStep]$_).title,$default)
			}
		}

		if (($steps | ForEach-Object { $_.Name }) -contains [SubordinateDatabaseVolumeSize].Name) {
			$message += "`n`n"
			$message += [DefaultVolumeSize]::subordinateDatabaseDescription
		}

		return $message
	}

	[bool]CanRun() {
		return -not $this.config.IsSystemSizeSpecified()
	}
}

[ConfigAttribute(("useVolumeSizeDefaults"))]
class VolumeSizeStep : Step {

	static [string] hidden $description = @'
Specify the amount of volume storage in gibibytes.
'@

	VolumeSizeStep([string] $name, 
		[string] $title, 
		[Config] $config) : base($name, 
			$config,
			$title,
			[VolumeSizeStep]::description,
			'Enter volume size (e.g., 64)') {}

	[IQuestion]MakeQuestion([string] $prompt) {
		return new-object IntegerQuestion($prompt, 1, [int]::MaxValue, $false)
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.HandleSizeResponse(([IntegerQuestion]$question).intResponse)
		return $true
	}

	[void]HandleSizeResponse([int] $size) {
		throw [NotImplementedException]
	}

	[bool]CanRun() {
		return -not $this.config.useVolumeSizeDefaults
	}
}

[ConfigAttribute(("webVolumeSizeGiB"))]
class WebVolumeSize : VolumeSizeStep {

	WebVolumeSize([Config] $config) : base([WebVolumeSize].Name, 'Web Volume Size', $config) {}

	[void]HandleSizeResponse([int] $size) {
		$this.config.webVolumeSizeGiB = $size
	}
	
	[void]Reset() {
		$this.config.webVolumeSizeGiB = [Config]::volumeSizeGiBDefault
	}

	[void]ApplyDefault() {
		$this.config.webVolumeSizeGiB = $this.GetDefault()
	}

	[string]GetDefault() {
		return '64'
	}
}

[ConfigAttribute(("dbVolumeSizeGiB","skipDatabase"))]
class MasterDatabaseVolumeSize : VolumeSizeStep {

	MasterDatabaseVolumeSize([Config] $config) : base([MasterDatabaseVolumeSize].Name, 'Master Database Volume Size', $config) {}

	[void]HandleSizeResponse([int] $size) {
		$this.config.dbVolumeSizeGiB = $size
	}

	[void]Reset() {
		$this.config.dbVolumeSizeGiB = [Config]::volumeSizeGiBDefault
	}

	[bool]CanRun() {
		return ([VolumeSizeStep]$this).CanRun() -and (-not ($this.config.skipDatabase))
	}

	[void]ApplyDefault() {
		$this.config.dbVolumeSizeGiB = $this.GetDefault()
	}

	[string]GetDefault() {
		return '64'
	}
}

[ConfigAttribute(("dbSlaveReplicaCount","dbSlaveVolumeSizeGiB","skipDatabase"))]
class SubordinateDatabaseVolumeSize : VolumeSizeStep {

	static [string] hidden $description = @'
Subordinate database containers use two volumes, the main database volume 
and a volume to store backup files. The volume size specified here applies to 
the data volume.
'@

	SubordinateDatabaseVolumeSize([Config] $config) : base([SubordinateDatabaseVolumeSize].Name, 'Subordinate Database Volume Size', $config) {}

	[void]HandleSizeResponse([int] $size) {
		$this.config.dbSlaveVolumeSizeGiB = $size
	}

	[void]Reset() {
		$this.config.dbSlaveVolumeSizeGiB = [Config]::volumeSizeGiBDefault
	}

	[bool]CanRun() {
		return ([VolumeSizeStep]$this).CanRun() -and (-not ($this.config.skipDatabase)) -and $this.config.dbSlaveReplicaCount -gt 0
	}

	[void]ApplyDefault() {
		$this.config.dbSlaveVolumeSizeGiB = $this.GetDefault()
	}

	[string]GetDefault() {
		return '64'
	}

	[string]GetMessage() {

		$message = [VolumeSizeStep]::description
		$message += "`n`n"
		$message += [SubordinateDatabaseVolumeSize]::description
		return $message
	}
}

[ConfigAttribute(("dbSlaveBackupVolumeSizeGiB","dbSlaveReplicaCount","skipDatabase"))]
class SubordinateDatabaseBackupVolumeSize : VolumeSizeStep {

	static [string] hidden $description = @'
Subordinate database containers use two volumes, the main database volume 
and a volume to store backup files. The volume size specified here applies to 
the backup volume.
'@

	SubordinateDatabaseBackupVolumeSize([Config] $config) : base([SubordinateDatabaseBackupVolumeSize].Name, 'Subordinate Database Backup Volume Size', $config) {}

	[void]HandleSizeResponse([int] $size) {
		$this.config.dbSlaveBackupVolumeSizeGiB = $size
	}

	[void]Reset() {
		$this.config.dbSlaveBackupVolumeSizeGiB = [Config]::volumeSizeGiBDefault
	}

	[bool]CanRun() {
		return ([VolumeSizeStep]$this).CanRun() -and (-not ($this.config.skipDatabase)) -and $this.config.dbSlaveReplicaCount -gt 0
	}

	[void]ApplyDefault() {
		$this.config.dbSlaveBackupVolumeSizeGiB = $this.GetDefault()
	}

	[string]GetDefault() {
		return '64'
	}

	[string]GetMessage() {

		$message = [VolumeSizeStep]::description
		$message += "`n`n"
		$message += [SubordinateDatabaseBackupVolumeSize]::description
		return $message
	}
}

[ConfigAttribute(("minioVolumeSizeGiB","skipMinIO","skipToolOrchestration"))]
class MinIOVolumeSize : VolumeSizeStep {

	MinIOVolumeSize([Config] $config) : base([MinIOVolumeSize].Name, 'MinIO Volume Size', $config) {}

	[void]HandleSizeResponse([int] $size) {
		$this.config.minioVolumeSizeGiB = $size
	}

	[void]Reset() {
		$this.config.minioVolumeSizeGiB = [Config]::volumeSizeGiBDefault
	}

	[bool]CanRun() {
		return ([VolumeSizeStep]$this).CanRun() -and -not $this.config.skipToolOrchestration -and -not $this.config.skipMinIO
	}

	[void]ApplyDefault() {
		$this.config.minioVolumeSizeGiB = $this.GetDefault()
	}

	[string]GetDefault() {
		return '64'
	}
}

[ConfigAttribute(("k8sProvider","storageClassName"))]
class StorageClassName : Step {

	static [string] hidden $description = @'
Specify a specific storage class that already exists on your Kubernetes 
cluster or press Enter to accept your cluster's default storage class. 

Note: Using a storage class associated with high speed storage (e.g., SSD) 
is recommended.
'@

	static [string] hidden $eksDescription = @'


If you plan to use EBS storage with your EKS cluster, remember to install the 
Amazon EBS CSI driver:

https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
'@

	StorageClassName([Config] $config) : base(
		[StorageClassName].Name, 
		$config,
		'Storage Class Name',
		[StorageClassName]::description,
		'Enter storage provider') { }

	[string]GetMessage() {

		$message = [StorageClassName]::description

		if ($this.config.k8sProvider -eq [ProviderType]::Eks) {
			$message += [StorageClassName]::eksDescription
		}
		return $message
	}

	[IQuestion]MakeQuestion([string] $prompt) {
		$question = new-object Question($prompt)
		$question.allowEmptyResponse = $true
		return $question
	}

	[bool]HandleResponse([IQuestion] $question) {
		$this.config.storageClassName = ([Question]$question).response
		return $true
	}

	[void]Reset() {
		$this.config.storageClassName = ''
	}
}
