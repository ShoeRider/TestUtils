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
	Import-Module $Dir\..\SystemTools.ps1
}
catch
{
	write-host "Unable to import SystemTools"
	pause
}


CheckForErrors -Message "Failed To initialize"
[TestTools]$TT = [TestTools]::new("$Dir\Tests", "General")
$Global:ReportToDisplay = $true
$Global:Testing         = $True
$Global:AllowCLS        = $False

Describe "General" {
	context "String Additions" {


	}

	It "ContainsCaracters" {
		$String = "ABC"
		$True_CharacterSets = @("A", "B", "C", "ABC", "AZE","BZE","CZE")
		$False_CharacterSets = @("D", "E", "F", "`nDE", "`tDE","ZE","TY")

		$True_CharacterSets | % {
			ContainsCharacter $String $_ | Should be $True
		}

		$False_CharacterSets | % {
			ContainsCharacter $String $_ | Should be $False
		}
	}

	It "ContainsCharacter" {
		$String = "ABC"
		$True_CharacterSets = @("A", "B", "C", "ABC", "AZE","BZE","CZE")
		$False_CharacterSets = @("D", "E", "F", "`nDE", "`tDE","ZE","TY")

		$True_CharacterSets | % {
			ContainsCharacter $String $_ | Should be $True
		}

		$False_CharacterSets | % {
			ContainsCharacter $String $_ | Should be $False
		}

	}
	It "PS_XCOPY_Old" {
		$TT.DeclareTest("PS_XCOPY_Old")
		$TT.CreateSourceTestFile("Temp.txt")
		GetFileCount($TT.Instance_SourceDir)   | Should Be 1


		CleanFolder($TT.Instance_SourceDir)
		Test-Path -Path $TT.Instance_SourceDir | Should Be $True
		GetFileCount($TT.Instance_SourceDir)   | Should Be 0
	}
	It "TT.RemovePath"{
		<#
		.SYNOPSIS

		#>
		$TT.DeclareTest("RemovePath")
		RemovePath($TT.InstanceDIR)
		Test-Path -Path $TT.InstanceDIR | Should Be $False
	}
	It "MakePath"{
		<#
		.SYNOPSIS

		#>
		$TT.DeclareTest("MakePath")
		$TestPath = Join-Path "$($TT.ClassDir)" "MakePath"
		RemovePath($TestPath)
		Test-Path -Path $TestPath | Should Be $False
		$TT.MakePath($TestPath)
		Test-Path -Path $TestPath | Should Be $True
	}
	It "CleanFolder"{
		<#
		.SYNOPSIS

		#>
		$TT.DeclareTest("CleanFolder")
		$TestPath = Join-Path "$($TT.ClassDir)" "MakePath"
		RemovePath($TestPath)
		Test-Path -Path $TestPath | Should Be $False
		$TT.MakePath($TestPath)
		Test-Path -Path $TestPath | Should Be $True
	}

				$ResultFiles  = $($((Get-ChildItem "$($TT.Instance_ResultDir)\" -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)

	It "Imports Join Library" {
		<#
		#Join Objects at element 
		if (Get-Module -ListAvailable -Name Join) {
			Write-Host "Module exists"
		} else {
			Install-Script -Name Join
		}
		#>
		
		$ExpectedObject = @{File="1";Hash0="123";Hash1="123"}
		$Object0 = @{File="1";Hash0="123"}
		$Object1 = @{File="1";Hash0="123"}
		$Object1.Hash1 = $Object1.hash0 
		$Object1.remove("Hash0")
		
		$JoinedObject = $Object0 | LeftJoin $Object1 -On File
		write-host $JoinedObject
		write-host $JoinedObject.getType()
		write-host $ExpectedObject
		write-host $ExpectedObject.getType()
		
		$($(Compare-Object $JoinedObject $ExpectedObject)) | Should Be $True
		$($(Compare-Object $JoinedObject $Object0))        | Should Be $False
	}

}
