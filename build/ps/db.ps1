function Test-DatabaseChartTag([string] $repoDir, [string] $tag) {
	Test-YamlField (Get-DatabaseValuesPath $repoDir) '.mariadb.image.tag' $tag
}

function Set-DatabaseChartTag([string] $repoDir, [string] $tag) {
	Set-YamlContentLine (Get-DatabaseValuesPath $repoDir) '.mariadb.image.tag' $tag
}

function Set-DatabaseDocTag([string] $repoDir, [string] $tag) {

	$semVersionPattern = Get-SemVerPattern
	(Get-RegistryDocPath $repoDir), (Get-RegistryScriptPath $repoDir) | ForEach-Object {
		$docPath = $_
		(Get-Content $docPath) -replace "codedx/codedx-mariadb:v$semVersionPattern","codedx/codedx-mariadb:$tag" | Set-Content $docPath
	}
}

function Set-DatabaseDeploymentGuideTag([string] $repoDir, [string] $tag) {

	$docPath = Get-DeploymentGuidePath $repoDir

	$pattern     = '\| mariadb.image.tag \| string \| `.+` \| the Docker image version for the MariaDB workload \|'
	$replacement = "| mariadb.image.tag | string | ``""$tag""`` | the Docker image version for the MariaDB workload |"

	(Get-Content $docPath) -replace $pattern,$replacement | Set-Content $docPath
}

function Test-RestoreDatabaseTag([string] $repoDir, [string] $tag) {

	$pattern = [Text.RegularExpressions.Regex]::Escape("'codedx/codedx-dbrestore:$tag'")
	$null -ne (get-content (Get-RestoreDatabaseScriptPath $repoDir) | select-string $pattern -Quiet)
}

function Set-RestoreDatabaseTag([string] $repoDir, [string] $tag) {

	$scriptPath = Get-RestoreDatabaseScriptPath $repoDir
	(get-content $scriptPath) -replace "'codedx/codedx-dbrestore:.+'","'codedx/codedx-dbrestore:$tag'" | Set-Content $scriptPath

	Set-NextScriptMinorVersion $scriptPath
}