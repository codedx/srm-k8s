# SRM Helm Prep Script

The [Helm Prep Wizard](../helm-prep-wizard.ps1) generates a config.json file that is provided as input to the [Helm Prep script](helm-prep.ps1). For field descriptions, refer to the [config.json appendix](../docs/DeploymentGuide.md#configjson).

## Tests

You can run the following command to execute tests in the ps directory:

```
$ pwsh
PS> cd /path/to/srm-k8s/ps
PS> Install-Module Pester -Force
PS> . .\external\powershell-algorithms\data-structures.ps1
PS> $results = Invoke-Pester tests -PassThru
```

>Note: Confirm that you have a newer Pester version (e.g., 5.7.1) should Invoke-Pester show this error message: "the BeforeAll command may only be used inside a Describe block."