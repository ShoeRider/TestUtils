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

Import-Module $Dir\..\SystemTools.ps1
write-host "$Dir\TestTools\TestTools.ps1"
Import-Module $Dir\TestTools\TestTools.ps1
	

[TestTools]$Global:TT = [TestTools]::new("$Dir\Tests", "General")
$Global:TestDir = switch (1)
{
    1 {"G:\PowershellEXE\General_Test_5\SRC\Tests\ExampleDIR"}
    2 {"G:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\"}
    3 {"It is three."}
    4 {"It is four."}
}

$Global:TestZip = switch (1)
{
    1 {"G:\PowershellEXE\General_Test_5\SRC\Tests\ExampleDIR.zip"}
    2 {"G:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\"}
    3 {"It is three."}
    4 {"It is four."}
}

$Global:ReportToDisplay = $True
$Global:Testing         = $True
$Global:AllowCLS        = $False


CheckForErrors -Message "Failed to Initialize"

if($False)
{
Describe "CheckSum" {
	context "GetFileHash" {
		It "Workes with Empty Files" {
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				$CheckSum.GetFileHash("D:\PowershellEXE\General_Test_5\SRC\Tests\ExampleDIR\EmptyFile.txt","MD5") | Should Be 0
				#df94116307cd650a0894cd5e1c5bfd57
		}
	}
	context "CheckSum base class" {
#CertutilCheckSum
		It "Initializes" {
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				$CheckSum.getType() | Should Be CheckSum
		}


		It "GetFolderHash" {
			if($false)
			{
				[CheckSum]$CheckSum = [CheckSum]::new()
				$Hash = $CheckSum.GetFolderHash("D:\PowershellEXE\General_Test_5\SRC\Tests\ExampleDIR","MD5")
				$Hash | Should be "d41d8cd98f00b204e9800998ecf8427e"

				#$Hash | Should be "ccab55b9b249ffb905cbadf4176fed42"
				$TT.DeclareTest("SaveOpenCheckSumXML")
				$XMLPath = Join-path $TT.Instance_ResultDir "XMLOut.xml"

				$CheckSum.SaveAsXML($XMLPath)
				Test-Path -Path $XMLPath | Should Be $true

				$CheckSum.CompareWithArchive($XMLPath) | Should Be $true

				$CheckSum.GetLogs()
				#$XMLObject.Jobs | Write-host $_
			}
		}
		It "OpenSavedXML FolderHash" {
			if($false)
			{
				[CheckSum]$CheckSum = [CheckSum]::new()
				$TT.DeclareTest("SaveOpenCheckSumXML") #Using the same save Directory as the
				$XMLPath = Join-path $TT.Instance_ResultDir "XMLOut.xml"
				write-host "Opening:$XMLPath"


				$CheckSum.MatchesXMLDictionary($XMLPath) | Should Be $true

				#write-host $XMLObject.GetLogs()
			}
		}

		It "PS_XCOPY" {
				#PS_XCOPY "$Global:TestDir\*" "B:\"
				#PS_XCOPY "$Global:TestDir\*" "B:\"
				#Copy-Item
		}


		It "PS_CopyItem" {
				$TT.DeclareTest("PS_CopyItem")
				$TT.CleanResultFolder()
				PS_CopyItem "$Global:TestDir\" "$($TT.Instance_ResultDir)\"

				$SourceFiles  = $($((Get-ChildItem "$Global:TestDir" -Recurse )           | where {$_ -is [System.IO.FileInfo]}).Count)
				$SourceFiles   | should not be 0
				$ResultFiles  = $($((Get-ChildItem "$($TT.Instance_ResultDir)\" -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
				$ResultFiles | Should be $SourceFiles
		}

		It "PS_XCOPY -CheckSum" {
				$TT.DeclareTest("PS_CopyItem_CheckSum")
				$TT.CleanResultFolder()
				PS_CopyItem "$Global:TestDir\" "$($TT.Instance_ResultDir)\" -CheckSum "MD5"


				$SourceFiles = $($((Get-ChildItem "$Global:TestDir" -Recurse )            | where {$_ -is [System.IO.FileInfo]}).Count)
				$SourceFiles   | should not be 0
				$ResultFiles  = $($((Get-ChildItem "$($TT.Instance_ResultDir)\" -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
				$ResultFiles | Should be $SourceFiles
		}

		It "PS_XCOPY -CheckSum" {
<#
$TT.DeclareTest("PS_CopyItem CheckSum")
$TT.CleanResultFolder()
PS_CopyItem "$Global:TestDir\*" "$($TT.Instance_ResultDir)\" -CheckSum "MD5"

$SourceFiles = $($((Get-ChildItem "$Global:TestDir" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count)
$SourceFiles   | should not be 0
$ResultFiles  = $($((Get-ChildItem "$($TT.Instance_ResultDir)\" -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
$ResultFiles | Should be $SourceFiles
#>
		}

		It "LongestLength_ofAttribute" {
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				$List = @()
				5..1 | % {
					$List += [pscustomobject]@{
						File     = "File$_"
						HASHTYPE = "HASHTYPE$_"
						Hash     = $_
					}
				}
				LongestLength_ofAttribute $List File
		}

	}
}
}


# ==========================================================
# DESCRIPTION:
#     Powershell Test declarations for TestTools
# ==========================================================
#
# Test:
#     powershell -NoProfile -ExecutionPolicy Bypass -file %~dp0\Utils\TestTools\TestTools_Test.ps1
# ==========================================================
if($True)
{


[TestTools]$TT = [TestTools]::new("$Dir\Tests", "DiskManagement")


#"E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\"

$Global:USBFilter  = @{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
$Global:USBFilters = @(
	@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
	@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
	)


Describe "FileSystem" {
			context "Initialize" {
		#CertutilCheckSum
				It "Initializes" {
						[FileSystem]$global:FileSystem = [FileSystem]::new()
				}
				It "`$FileSystem.GetFileList" {
						[FileSystem]$global:FileSystem = [FileSystem]::new()
						$FileList = $FileSystem.GetFileList($Global:TestImage)
						write-host $FileList.count
						#df94116307cd650a0894cd5e1c5bfd57
				}
				It "`$FileSystem.GetFileCount" {
						[FileSystem]$global:FileSystem = [FileSystem]::new()
						write-host $FileSystem.GetFileCount($Global:TestImage)
						#df94116307cd650a0894cd5e1c5bfd57
				}
			}

}



