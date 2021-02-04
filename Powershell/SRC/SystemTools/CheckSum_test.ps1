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
	write-host "$Dir\TestTools\TestTools.ps1"
	Import-Module $Dir\TestTools\TestTools.ps1
}
catch
{
	write-host "Unable to import SystemTools"
	pause
}


CheckForErrors -Message "Failed To initialize"
[TestTools]$TT = [TestTools]::new("$Dir\Tests", "General")


Describe "CheckSum" {
	context "CheckSum base class" {
#CertutilCheckSum
		It "Initializes" {
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				write-host $CheckSum.getType()
		}
		It "GetFileHash" {
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				write-host $CheckSum.GetFileHash("D:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\Boot\bcd.LOG1","MD5")
				#df94116307cd650a0894cd5e1c5bfd57
		}
		It "GetFolderHash" {
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				$Hash = $CheckSum.GetFolderHash("D:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\","MD5")
				$Hash | Should be "ccab55b9b249ffb905cbadf4176fed42"

				write-host $hash
				write-host $CheckSum.Get_StringHash("","MD5").toString()
				#d41d8cd98f00b204e9800998ecf8427e
				write-host $CheckSum.GetLogs()
		}


	}


}
