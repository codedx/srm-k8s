function Get-TestDriveDirectoryInfo() {

	$TestDrive -is [IO.DirectoryInfo] ? $TestDrive : (New-Object IO.DirectoryInfo($TestDrive))
}