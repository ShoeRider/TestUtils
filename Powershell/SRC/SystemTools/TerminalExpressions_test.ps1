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
try{

	Import-Module "$Dir\..\SystemTools.ps1"
	#Import-Module $Dir\ErrorHandling.ps1
	#Import-Module $Dir\ErrorHandling.ps1
	#Import-Module $Dir\..\TestTools\TestTools.ps1
}
catch
{
	write-host "Unable to import SystemTools: $Dir\..\SystemTools.ps1"
	pause
}

CheckForErrors -Message "Failed To initialize"

#New-ModuleManifest $Dir\TestTools.ps1
Describe "TerminalExpressions" {
	context "Initialize" {
		It "Initializes" {
			<#
			.SYNOPSIS

			#>
		}
		It "Set_WindowSize" {
			<#
			.SYNOPSIS

			#>
			$DefaultWidth  = $host.ui.rawui.windowsize.width
			$DefaultHeight = $host.ui.rawui.windowsize.height
			Set_WindowSize -x 10 -y 10
      $host.ui.rawui.windowsize.width  | Should Be 10
      $host.ui.rawui.windowsize.height | Should Be 10

			Set_WindowSize -x $DefaultWidth -y $DefaultHeight
			$host.ui.rawui.windowsize.width  | Should Be $DefaultWidth
			$host.ui.rawui.windowsize.height | Should Be $DefaultHeight
		}

		It "Set_ScreenMode" {
			<#
			.SYNOPSIS

			#>
			$DefaultBackgroundcolor  = $host.ui.rawui.backgroundcolor
			$DefaultForegroundcolor = $host.ui.rawui.foregroundcolor
			$global:ColorOptions.keys | % {
				#write-host
				Set_ScreenMode -Mode $_
				$host.ui.rawui.backgroundcolor | should be $global:ColorOptions[$_]["backgroundcolor"]
				$host.ui.rawui.foregroundcolor | should be $global:ColorOptions[$_]["foregroundcolor"]
				# $global:ColorOptions
			}

			$host.ui.rawui.backgroundcolor = $DefaultBackgroundcolor
			$host.ui.rawui.foregroundcolor = $DefaultForegroundcolor
		}

		It "Validate-Param" {
			<#
			.SYNOPSIS

			#>
			Validate_Param -value 10  -ValidateType 'System.Int32'  | should be $True
			Validate_Param -value "ABC"                             | should be $True
			Validate_Param -value "ABC" -ValidateLength 3           | should be $True


			Validate_Param -value "ABC" -ValidateType "String"      | should be $True
			Validate_Param -value "10A" -StringToInteger            | should be $False
	}
}




}
