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

try{

	#Import-Module $Dir\..\SystemTools.ps1
	write-host "$Dir\..\SystemTools.ps1"
	Import-Module $Dir\..\SystemTools.ps1
	write-host "$Dir\TestTools\TestTools.ps1"
	Import-Module $Dir\TestTools\TestTools.ps1
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


<#
$allscripts = Get-ChildItem -Path "$Dir\" | where-object{$_.Name.endswith(".ps1")  } | Select-Object -ExpandProperty FullName
foreach ($script in $allscripts) {
	#write-host "Importing $script"
	#Import-Module "$script"
	$ScriptPath = $script.Split(".")
	#write-host $script $script.GetType() $ScriptPath
	if(-not $($ScriptPath[0]).EndsWith("_test"))
	{

		write-host "Import-Module:$script $ManifestPath"
		Import-Module "$script" -Verbose:$false
		#Import-Module "$script '$ManifestPath'" -Verbose:$false
		#Invoke-expression "powershell.exe $script $ManifestPath"
	}

}
#>

#TODO Figure out psOBJECT line declarations
#new-Object PsObject -property @{Name='donald'; Kind='duck' }
#$PrepedDiskObject | Add-Member -MemberType AliasProperty -Name "Disk" -InputObject $Disk


CheckForErrors -Message "Failed To initialize"

[TestTools]$TT = [TestTools]::new("$Dir\Tests", "DiskManagement")
#Declare USB being used for testing
$Global:USBFilter  = @{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
$Global:USBFilters = @(
	@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
	@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
	@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
	)




Describe "Disk" {
	context "Initialize" {
		It "Initializes" {
			<#
			.SYNOPSIS

			#>
			$DiskFormat = @{
				"PartitionStyle"     = "MBR";
				"FileSystem"         = "NTFS";
				"AllocationUnitSize" = 4096;
				"NewFileSystemLabel" = "Win_PE_Console"
			}

			$FilteredDisks = @()
			$Disks = get-disk

			#Filter full list with Filter options. Filter options example: $FilterOptions = @{"BusType"="USB"}
			foreach($Option in ($Global:USBFilter.keys))
			{
				iex "`$Disks = `$Disks | Where-Object $Option -eq `"$($Global:USBFilter[$Option])`""
			}

			#for each disk in list Create Disk objects, and add to FilteredDisks list
			foreach($Disk in $Disks)
			{
				[Disk]$DiskObject = [Disk]::new($Disk,$DiskFormat)

				$FilteredDisks += $DiskObject
			}

		}
	it "GetAvailableDriveLetter"{
		[Disk]$DiskObject = [Disk]::new()
	}

	}



}
#Get_NADDrives

#New-ModuleManifest $Dir\TestTools.ps1
Describe "DiskManagement" {
	context "Initialize" {
		It "Initializes" {
			<#
			.SYNOPSIS

			#>
			$DiskFormat = @{
				"PartitionStyle"     = "MBR";
				"FileSystem"         = "NTFS";
				"AllocationUnitSize" = 4096;
				"NewFileSystemLabel" = "Win_PE_Console"
			}
			[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)


		}
		It "Initializes with Filters" {
			<#
			.SYNOPSIS

			#>
			$DiskFormat = @{
				"PartitionStyle"     = "MBR";
				"FileSystem"         = "NTFS";
				"AllocationUnitSize" = 4096;
				"NewFileSystemLabel" = "Win_PE_Console"
			}
			# ==========================================================
			# DESCRIPTION:
			#	one item filters being applied with Select_Disks
			# ==========================================================
			$USBFilters = @(
				@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
			)
			[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
			$DiskManagement.Select_Disks($USBFilters)
			$DiskManagement.getcount() | Should be 1
			
			
			# ==========================================================
			# DESCRIPTION:
			#	Two item filters being applied with Select_Disks
			# ==========================================================
			$USBFilters = @(
				@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
				@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
			)
			[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
			$DiskManagement.Select_Disks($USBFilters)
			$DiskManagement.getcount() | Should be 2
			
			
			# ==========================================================
			# DESCRIPTION:
			#	Duplicated item filters being applied with Select_Disks.
			# Filtering for duplicate disks being found
			# ==========================================================
			$USBFilters = @(
				@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
				@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
				@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
			)
			[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
			$DiskManagement.Select_Disks($USBFilters)
			$DiskManagement.getcount() | Should be 2
		}
	}

	context "CleansDisk" {
		It "Finds one Disk" {
			<#
			.SYNOPSIS

			#>
			if($false)
			{
				$TT.DeclareTest("ZIP")
				[DiskManagement]$DiskManagement = [DiskManagement]::new($Global:USBFilter)
				#write-host $DiskManagement.FilteredDisks[0]
				#write-host $DiskManagement.FilteredDisks.gettype()
				#pause
				$DiskManagement.getcount() | Should be 2
				$DiskManagement.PrepDisks('NTFS')
				#"$Dir\TestZip.zip"

				#$DiskManagement.ApplyZip("$($TT.Instance_SourceDir)\TestZip.zip")
			}

		}
		It "Applies ZIP" {
			<#
			.SYNOPSIS

			#>

			if($false)
			{
				Disable_AutoMount
				$TT.DeclareTest("ZIP")
				[DiskManagement]$DiskManagement = [DiskManagement]::new($Global:USBFilter)
				#write-host $DiskManagement.FilteredDisks[0]
				#write-host $DiskManagement.FilteredDisks.gettype()
				#pause
				$DiskManagement.getcount() | Should be 1
				$DiskManagement.PrepDisks('NTFS')
				#"$Dir\TestZip.zip"

				$Source_HashCode = "Fake HASH"
				#$Source_HashCode = ( Get-ChildItem "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759" -Recurse | Get-FileHash).Hash

				#$Source_HashCode = Get-FolderHash_1("$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759")

				#$Source_HashCode = Get-FolderHash "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759"
				write-host "$($TT.Instance_SourceDir)\I-20233-3759       | Should be `$True"
				$TT.IsFile("$($TT.Instance_SourceDir)\I-20233-3759.zip") | Should be $True
				#pause
				#$DiskManagement.ApplyFolderContents("$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759",$Source_HashCode)
				$CID            = 88888888
				$OrderNumber    = 12345678


				$DiskManagement.SaveLogs("Z:\",$CID,$OrderNumber)
				Enable_AutoMount
			}
		}
		It "SaveLogs" {
			<#
			.SYNOPSIS

			#>


			if($false)
			{
				$TT.DeclareTest("ZIP")
				[DiskManagement]$DiskManagement = [DiskManagement]::new($Global:USBFilter)
				#write-host $DiskManagement.FilteredDisks[0]
				#write-host $DiskManagement.FilteredDisks.gettype()
				#pause
				$DiskManagement.getcount() | Should be 1
				$DiskManagement.PrepDisks('NTFS')
				$CID            = 88888888
				$OrderNumber    = 12345678


				$DiskManagement.SaveLogs($CID,$OrderNumber)
			}
		}
	}

}
pause
#CheckForErrors -Message "Something unexpected Happened"
