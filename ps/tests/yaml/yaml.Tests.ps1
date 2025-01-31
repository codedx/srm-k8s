using module @{ModuleName='guided-setup'; RequiredVersion='1.18.0' }

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Import-Module 'pester' -ErrorAction SilentlyContinue
if (-not $?) {
	Write-Host 'Pester is not installed, so this test cannot run. Run pwsh, install the Pester module (Install-Module Pester), and re-run this script.'
	exit 1
}

BeforeAll {
	. (Join-Path $PSScriptRoot '../../external/powershell-algorithms/data-structures.ps1')
	. (Join-Path $PSScriptRoot '../../build/yaml.ps1')
}

Describe 'Merge YAML files' -Tag 'YAML' {

    It 'should combine nodes that do not overlap' {

        @'
root:
  foo: foo
'@ | Out-File 'TestDrive:\left.yaml'

        @'
root:
  bar: bar
'@ | Out-File 'TestDrive:\right.yaml'

        $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')

        @'
root: 
  foo: foo
  bar: bar

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should override overlapping tag value' {

        @'
root:
  foo: foo
'@ | Out-File 'TestDrive:\left.yaml'

        @'
root:
  foo: bar
'@ | Out-File 'TestDrive:\right.yaml'

        $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')

        @'
root: 
  foo: bar

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should override overlapping tag value hierarchy' {

        @'
root:
  foo: foo
'@ | Out-File 'TestDrive:\left.yaml'

        @'
root:
  foo:
    bar: bar
      foo: foo
    foo: foo
'@ | Out-File 'TestDrive:\right.yaml'

        $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
        @'
root: 
  foo: 
    bar: bar
      foo: foo
    foo: foo

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should override overlapping array' {

      @'
root:
- foo
'@ | Out-File 'TestDrive:\left.yaml'

      @'
root:
- foo
- bar
'@ | Out-File 'TestDrive:\right.yaml'

      $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
      @'
root: 
- foo
- bar

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should copy block scalar string that keeps newlines w/o ending newline' {

    @'
root:
  foo: |
    This string spans two
    lines
  bar: test
'@ | Out-File 'TestDrive:\left.yaml'

    @'
root:
  foo: |-
    This string spans three
    lines instead of spanning
    two lines
'@ | Out-File 'TestDrive:\right.yaml'

    $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
    @'
root: 
  foo: |-
    This string spans three
    lines instead of spanning
    two lines
  bar: test

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should copy block scalar string that keeps newlines w/ all ending newlines' {

    @'
root:
foo: |
  This string spans two
  lines
bar: test
'@ | Out-File 'TestDrive:\left.yaml'

    @'
root:
foo: |+
  This string spans three
  lines instead of spanning
  two lines
'@ | Out-File 'TestDrive:\right.yaml'

    $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
    @'
root: 
foo: |+
  This string spans three
  lines instead of spanning
  two lines
bar: test

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should copy block scalar string that keeps newlines w/ single ending newline' {

    @'
root:
foo: |+
  This string spans two
  lines
bar: test
'@ | Out-File 'TestDrive:\left.yaml'

    @'
root:
foo: |
  This string spans three
  lines instead of spanning
  two lines
'@ | Out-File 'TestDrive:\right.yaml'

    $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
    @'
root: 
foo: |
  This string spans three
  lines instead of spanning
  two lines
bar: test

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should copy block scalar string that replaces newlines w/o ending newline' {

    @'
root:
  foo: |
    This string spans two
    lines
  bar: test
'@ | Out-File 'TestDrive:\left.yaml'

    @'
root:
  foo: >-
    This string spans three
    lines instead of spanning
    two lines
'@ | Out-File 'TestDrive:\right.yaml'

    $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
    @'
root: 
  foo: >-
    This string spans three
    lines instead of spanning
    two lines
  bar: test

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should copy block scalar string that replaces newlines w/ all ending newlines' {

    @'
root:
foo: |
  This string spans two
  lines
bar: test
'@ | Out-File 'TestDrive:\left.yaml'

    @'
root:
foo: >+
  This string spans three
  lines instead of spanning
  two lines
'@ | Out-File 'TestDrive:\right.yaml'

    $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
    @'
root: 
foo: >+
  This string spans three
  lines instead of spanning
  two lines
bar: test

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should copy block scalar string that replaces newlines w/ single ending newline' {

    @'
root:
foo: |+
  This string spans two
  lines
bar: test
'@ | Out-File 'TestDrive:\left.yaml'

    @'
root:
foo: >
  This string spans three
  lines instead of spanning
  two lines
'@ | Out-File 'TestDrive:\right.yaml'

    $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')
    @'
root: 
foo: >
  This string spans three
  lines instead of spanning
  two lines
bar: test

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }

    It 'should combine arrays that do not overlap' {

      @'
root:
  - foo1:
    foo2: foo2
'@ | Out-File 'TestDrive:\left.yaml'

      @'
root:
  - bar1:
    bar2: bar2
'@ | Out-File 'TestDrive:\right.yaml'

      $yaml = Merge-YamlFiles @('TestDrive:\left.yaml','TestDrive:\right.yaml')

      @'
root: 
  - foo1: 
    foo2: foo2
  - bar1: 
    bar2: bar2

'@ -eq $yaml.ToYamlString() | Should -BeTrue
    }
}