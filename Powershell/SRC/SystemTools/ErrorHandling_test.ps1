# ==========================================================
# DESCRIPTION:
#     Powershell Test declarations for TestTools
# ==========================================================
#
# Test:
#     powershell -NoProfile -ExecutionPolicy Bypass -file %~dp0\Utils\TestTools\TestTools_Test.ps1
# ==========================================================

$Dir = split-path -parent $MyInvocation.MyCommand.Definition
$global:Dir = $($Dir.Substring(0,$($Dir.Length)))

#invoke-expression -Command ./../SRC/General.ps1
#Invoke-expression "$Dir\..\SystemTools.ps1 Temp.ini"
#Import-Module $Dir\..\SystemTools.ps1

#Invoke-expression "powershell.exe $Dir\..\SystemTools.ps1 $Dir\..\Temp.ini"
try{

	#Import-Module $Dir\..\SystemTools.ps1
	write-host "$Dir\..\SystemTools.ps1 $Dir\..\Temp.ini"
	Import-Module $Dir\..\SystemTools.ps1
	#Invoke-expression "powershell.exe $Dir\..\SystemTools.ps1 $Dir\..\Temp.ini"
	#Import-Module $Dir\ErrorHandling.ps1
	#Import-Module $Dir\ErrorHandling.ps1
	#Import-Module $Dir\..\TestTools\TestTools.ps1
}
catch
{
	write-host "Unable to import SystemTools"
	pause
}

write-host ""
[ErrorHandling]$global:ErrorHandling = [ErrorHandling]::new(@("View"))
pause
#New-ModuleManifest $Dir\TestTools.ps1
Describe "ErrorHandling" {
	context "Initialize" {
		It "Initializes" {
			<#
			.SYNOPSIS

			#>
			[ErrorHandling]$global:ErrorHandling = [ErrorHandling]::new(@("View"))
			[ErrorHandling]$global:ErrorHandling = [ErrorHandling]::new("View")
		}
		It "ErrorHandling.CreateErrorOptions" {
			<#
			.SYNOPSIS

			#>
			[ErrorHandling]$global:ErrorHandling = [ErrorHandling]::new(@("View","Logs","Continue"))

			#Display_Error_Message

		}
		It "ErrorHandling.CreateErrorOptions" {
			<#
			.SYNOPSIS

			#>
			Display_Error_Message -Message "Test" -Message2 "Test"  -Message3 "Test" 

			#Display_Error_Message

		}
#

	}





}
