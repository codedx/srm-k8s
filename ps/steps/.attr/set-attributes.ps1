<#PSScriptInfo
.VERSION 1.0.0
.GUID 5a8e4d1b-7f8c-4f8d-a35f-496de2b3ff44
.AUTHOR Black Duck
.COPYRIGHT Copyright 2025 Black Duck Software, Inc. All rights reserved.
#>

$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

# Fetch "step" files to conditionally add attributes with related config.json field names. Skip the
# step.ps1 file, which contains the base step class definition.
Get-ChildItem "$PSScriptRoot/.." -File | Where-Object { $_.Name -ne 'step.ps1' } | ForEach-Object {

	Write-Host "Processing $_..."

	$tokens = @()
	$errors = @()
	$filePath = $_
	$parsedFile = [Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$tokens, [ref]$errors)

	# Find all references to config.json fields
	$configMembers = $parsedFile.FindAll( { $args[0] -is [Management.Automation.Language.MemberExpressionAst] }, $true ) | Where-Object {
		$null -ne $_.Expression -and $_.Expression.toString() -eq '$this.config'
	}

	$configAttributes = @{}

	# The config.json fields have lowercase names
	$configMembersToSkip = @('notes')
	$configMembers | Where-Object { $_.Member.Value -cmatch '^[a-z].*' } | Where-Object { $configMembersToSkip -notcontains $_.Member.Value } | ForEach-Object {

		# Find the class name that contains this member reference
		$parent = $_.Parent
		while ($null -ne $parent -and $parent.GetType().Name -ne 'TypeDefinitionAst') {
			$parent = $parent.Parent
		}

		if ($parent -eq $null) {
			throw "Unexpectedly found member '$($_.Member.Value)' without a TypeDefinitionAst parent"
		}

		if (-not $configAttributes.ContainsKey($parent)) {
			$configAttributes[$parent] = New-object Collections.Generic.HashSet[string]
		}

		# Add class member reference with a link to the related class
		$configAttributes[$parent].Add($_.Member.Value) | Out-Null
	}

	# For each class, insert an attribute or update an existing one
	$fileContents = Get-Content $filePath
	$configAttributes.Keys | Sort-Object -Property {$_.Extent.StartLineNumber} -Descending | ForEach-Object {

		$memberSet = $configAttributes[$_]

		$attr = "[ConfigAttribute((`"$(([string]::join('","',($memberSet | Sort-Object | ForEach-Object { $_ }))))`"))]"

		$startLineIndex = $_.Extent.StartLineNumber - 1

		if ($fileContents[$startLineIndex] -like '`[ConfigAttribute*') {
			$fileContents[$startLineIndex] = $attr
		} else {
			if ($_.Extent.StartLineNumber -eq 1) {
				$fileContents = @($attr) + $fileContents
			} else {
				$fileContents = $fileContents[0..($startLineIndex - 1)] + @($attr) + $fileContents[($startLineIndex)..($fileContents.Length - 1)]
			}
		}
	}

	$fileContents | Set-Content -LiteralPath $filePath
}
