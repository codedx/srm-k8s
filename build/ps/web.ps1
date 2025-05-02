function Test-WebChartTag([string] $repoDir, [string] $tag) {
	Test-YamlField (Get-WebValuesPath $repoDir) '.web.image.tag' $tag
}

function Set-WebChartTag([string] $repoDir, [string] $tag) {
	Set-YamlContentLine (Get-WebValuesPath $repoDir) '.web.image.tag' $tag
}

function Set-WebRegistryDocTag([string] $repoDir, [string] $tag) {

	$semVersionPattern = Get-SemVerPattern
	(Get-RegistryDocPath $repoDir), (Get-RegistryScriptPath $repoDir) | ForEach-Object {
		$docPath = $_
		(Get-Content $docPath) `
			-replace "codedx/codedx-tomcat:v$semVersionPattern","codedx/codedx-tomcat:$tag" `
			-replace "codedx/codedx-tools:v$semVersionPattern","codedx/codedx-tools:$tag" | Set-Content $docPath
	}
}

function Set-WebDeploymentGuideTag([string] $repoDir, [string] $tag) {

	$docPath = Get-DeploymentGuidePath $repoDir

	$pattern     = '\| web.image.tag \| string \| `.+` \| the Docker image version for the SRM web workload \|'
	$replacement = "| web.image.tag | string | ``""$tag""`` | the Docker image version for the SRM web workload |"

	(Get-Content $docPath) -replace $pattern,$replacement | Set-Content $docPath
}