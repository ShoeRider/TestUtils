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


write-host "$Dir\TestTools.ps1"
#invoke-expression -Command ./../SRC/General.ps1
try{
	Import-Module $Dir/TestTools.ps1
}
catch
{
	write-host "Unable to import TestTools"
	pause
}


#New-ModuleManifest $Dir\TestTools.ps1
Describe "TestTools" {
	Import-Module $Dir/TestTools.ps1

	context "Basic Functionality" {
		It "Initializes" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
		}
		It "TT.RemovePath"{
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$TT.DeclareTest("RemovePath")
			$TT.RemovePath($TT.InstanceDIR)
			Test-Path -Path $TT.InstanceDIR | Should Be $False
		}
		It "TT.MakePath"{
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$TT.DeclareTest("MakePath")
			$TestPath = Join-Path "$($TT.ClassDir)" "MakePath"
			$TT.RemovePath($TestPath)
			Test-Path -Path $TestPath | Should Be $False
			$TT.MakePath($TestPath)
			Test-Path -Path $TestPath | Should Be $True
		}



		It "TT.IsFolder" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$Folder = $TT.DeclareTest("IsFolder")
			$File = "$($Folder)\Test.txt"
			echo "Create File" > $File
			$TT.IsFolder($Folder) | Should Be $True
			$TT.IsFolder($File)   | Should Be $False

			$TT.IsFolder("Not A Path") | Should Be $False
		}
		It "TT.IsFile" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$Folder = $TT.DeclareTest("IsFolder")
			$File = "$($Folder)\Test.txt"
			echo "Create File" > $File
			$TT.IsFile($Folder) | Should Be $False
			$TT.IsFile($File)   | Should Be $True

			$TT.IsFile("Not A Path") | Should Be $False
		}

		It "TT.IsType" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$Folder = $TT.DeclareTest("IsType")
			#$File = "$($Folder)\Test.txt"
			# "Create File" > $File
			$TT.IsType("String",[type][String]) | Should Be $True
			$TT.IsType(10,[type][int])          | Should Be $True

			$TT.IsType($TT,[type][TestTools])   | Should Be $True
			$TT.IsType($TT,[TestTools])         | Should Be $True

			#$TT.IsType($TT,[NoType])         | Should Be $False
			#$TT.IsType("String",[NoType])         | Should Be $False
		}



	}
	context "Creates Folders Appropriately " {
		It "TT.ClassDir is created" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			Test-Path -Path "$($TT.ClassDir)" | Should Be $True
		}
		It "TT.DeclareContext Creates ContextDIR Folder" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$ContextDir = $TT.DeclareContext("ContextDIR")
			$TT.RemovePath($ContextDir)
			$ContextDir = $TT.DeclareContext("ContextDIR")
			Test-Path -Path $ContextDir | Should Be $True
		}
		It "TT.DeclareContext has no InstanceDIR/Instance_SourceDir/Instance_ResultDir" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$ContextDir = $TT.DeclareContext("ContextDIR")
			Test-Path -Path $ContextDir | Should Be $True
			$TT.InstanceDIR        | Should Be ""
			$TT.Instance_SourceDir | Should Be ""
			$TT.Instance_ResultDir | Should Be ""
		}

		It "TT.DeclareTest With out Context" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$TT.DeclareTest("Test")
			Test-Path -Path $TT.Instance_SourceDir | Should Be $True
			Test-Path -Path $TT.Instance_ResultDir | Should Be $True
		}

		It "TT.DeclareTest With Context" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$TT.DeclareContext("ContextDIR")
			$TT.DeclareTest("With a Context")
			Test-Path -Path $TT.Instance_SourceDir | Should Be $True
			Test-Path -Path $TT.Instance_ResultDir | Should Be $True
		}

		It "TT.DeclareTest clears Paths after new Context" {
			<#
			.SYNOPSIS

			#>
			[TestTools]$TT = [TestTools]::new("$Dir\Tests", "TestTools")
			$TT.DeclareContext("ContextDIR")
			$TT.DeclareTest("With a Conext")
			Test-Path -Path $TT.Instance_SourceDir | Should Be $True
			Test-Path -Path $TT.Instance_ResultDir | Should Be $True
			$TT.DeclareContext("ContextDIR")
			$TT.InstanceDIR        | Should Be ""
			$TT.Instance_SourceDir | Should Be ""
			$TT.Instance_ResultDir | Should Be ""
		}

	}




}
