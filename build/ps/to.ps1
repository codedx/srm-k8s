function Test-ToolOrchestrationChartTag([string] $repoDir, [string] $tag) {
	Test-YamlField (Get-ToolOrchestrationValuesPath $repoDir) '.to.image.tag' $tag
}

function Test-WorkflowChartTag([string] $repoDir, [string] $tag) {
	Test-YamlField (Get-ToolOrchestrationValuesPath $repoDir) '.argo-workflows.images.tag' $tag
}

function Set-ToolOrchestrationChartTag([string] $repoDir, [string] $tag) {
	Set-YamlContentLine (Get-ToolOrchestrationValuesPath $repoDir) '.to.image.tag' $tag
}

function Set-ToolOrchestrationRegistryDocTag([string] $repoDir, [string] $tag) {

	$semVersionPattern = Get-SemVerPattern
	(Get-RegistryDocPath $repoDir), (Get-RegistryScriptPath $repoDir) | ForEach-Object {

		$docPath = $_
		(Get-Content $docPath) `
			-replace "codedx/codedx-prepare:v$semVersionPattern","codedx/codedx-prepare:$tag" `
			-replace "codedx/codedx-newanalysis:v$semVersionPattern","codedx/codedx-newanalysis:$tag" `
			-replace "codedx/codedx-results:v$semVersionPattern","codedx/codedx-results:$tag" `
			-replace "codedx/codedx-tool-service:v$semVersionPattern","codedx/codedx-tool-service:$tag" `
			-replace "codedx/codedx-cleanup:v$semVersionPattern","codedx/codedx-cleanup:$tag" | Set-Content $docPath
	}
}

function Set-ToolOrchestrationDeploymentGuideTag([string] $repoDir, [string] $tag) {

	$docPath = Get-DeploymentGuidePath $repoDir

	$pattern     = '\| to.image.tag \| string \| `.+` \| the Docker image version for the SRM Tool Orchestration workloads \(tools use the web.image.tag version\)\|'
	$replacement = "| to.image.tag | string | ``""$tag""`` | the Docker image version for the SRM Tool Orchestration workloads (tools use the web.image.tag version)|"

	(Get-Content $docPath) -replace $pattern,$replacement | Set-Content $docPath
}