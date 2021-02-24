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



Describe "DiskPartition" {
	It "Initializes" {
			#[DiskPartition]$global:DiskPartition = [DiskPartition]::new($DiskNumber,$PartitionNumber)
	}
	It "DiskManagement.GetDiskNumbers" {

			[DiskManagement]$DiskManagement = [DiskManagement]::new($Global:USBFilters)
			$DriveNumbers =  $DiskManagement.GetDiskNumbers()
			write-host $DriveNumbers
			$DriveNumbers.Length | should be 1
			#$DriveNumbers 
	}
	It "ChangeDriveLabel" {

		if($False)
		{
			[DiskManagement]$DiskManagement = [DiskManagement]::new($Global:USBFilters)
			$DiskManagement.getcount() | Should be 1
			$DriveNumbers =  $DiskManagement.GetDiskNumbers()
			write-host "DriveNumbers: $DriveNumbers"
			$DriveNumbers | % {
				write-host "Disk Number: $_"
				$_ | Should not be 0
				
				[Disk]$global:Disk = [Disk]::new($_)
				
				[DiskPartition]$global:DiskPartition = [DiskPartition]::new($_,0)
				
			}
		}

			#[DiskPartition]$global:DiskPartition = [DiskPartition]::new($DiskNumber,$PartitionNumber)
	}
	#
			context "Initialize" {
		#CertutilCheckSum

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

	Describe "Disk" {
		context "Initialize" {
			It "Initializes" {
				if($true)
				{
					<#
					.SYNOPSIS

					#>
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
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
						[Disk]$DiskObject = [Disk]::new($Disk)
						write-host $Disk  #| out-string
						$FilteredDisks += $DiskObject
					}
					$FilteredDisks.count | Should be 1
					$FilteredDisks | %{
						#$_.PrepDisk($DiskFormat)
						$_.Clear_Disk()

						$DiskPartition = @{
							PartitionStyle     = "MBR";
							PartitionSize      = 100MB;
							FileSystem         = "NTFS";
							BlockSize          = 4096;
							Label              = "Win_PE_Console_0";
							ApplyZIP           = $Global:TestZip;
						}

						$NewPartition = $_.CreateCustomPartition($DiskPartition)
						write-host $($NewPartition | Format-List | out-string)
						write-host $NewPartition.DiskNumber
						write-host $NewPartition.PartitionNumber
						write-host $NewPartition.DriveLetter

						$DiskPartition = @{
							PartitionStyle     = "MBR";
							PartitionSize      = 100MB;
							FileSystem         = "NTFS";
							BlockSize          = 4096;
							Label              = "Win_PE_Console_1"
						}
						$NewPartition = $_.CreateCustomPartition($DiskPartition)
						write-host $($NewPartition | Format-List | out-string)
						#$_.CheckDisk() | Should be $true
						$DiskPartitions = @(
								@{
									PartitionStyle     = "MBR";
									PartitionSize      = 100MB;
									FileSystem         = "NTFS";
									BlockSize          = 4096;
									Label              = "Win_PE_Console_0";
									ApplyZIP           = $Global:TestZip;
							},
								@{
									PartitionStyle     = "MBR";
									PartitionSize      = 100MB;
									FileSystem         = "NTFS";
									BlockSize          = 4096;
									Label              = "Win_PE_Console_1";
									ApplyZIP           = $NULL;
							}
						)
					}
				}


			}
			
			It "Initializes" {
				if($true)
				{
					<#
					.SYNOPSIS

					#>
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
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
						[Disk]$DiskObject = [Disk]::new($Disk)
						write-host $Disk  #| out-string
						$FilteredDisks += $DiskObject
					}
					$FilteredDisks.count | Should be 1
					$FilteredDisks | %{
						#$_.PrepDisk($DiskFormat)
						$_.Clear_Disk()

						$DiskPartitions = @(
								@{
									PartitionStyle     = "MBR";
									PartitionSize      = 100MB;
									FileSystem         = "NTFS";
									BlockSize          = 4096;
									Label              = "Win_PE_Console_0";
									ApplyZIP           = $Global:TestZip;
							},
								@{
									PartitionStyle     = "MBR";
									PartitionSize      = 100MB;
									FileSystem         = "NTFS";
									BlockSize          = 4096;
									Label              = "Win_PE_Console_1";
									ApplyZIP           = $NULL;
							}
						)

						$NewPartition = $_.ApplyPartitions($DiskPartitions)
						$_.CheckPartitions() | should be $False
						write-host $($NewPartition | Format-List | out-string)
						write-host $NewPartition.DiskNumber
						write-host $NewPartition.PartitionNumber
						write-host $NewPartition.DriveLetter


						#$_.CheckDisk() | Should be $true

					}
				}


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
					"BlockSize" = 4096;
					"NewFileSystemLabel" = "Win_PE_Console"
				}
				[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
			}

			It "Initializes with Filters" {
				<#
				.SYNOPSIS

				#>
				if($False)
				{
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
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
		}

		context "CleansDisk" {
			It "Finds one Disk" {
				<#
				.SYNOPSIS

				#>
				$DiskFormat = @{
					"PartitionStyle"     = "MBR";
					"FileSystem"         = "NTFS";
					"BlockSize" = 4096;
					"NewFileSystemLabel" = "Win_PE_Console"
				}
				$USBFilters = @(
					@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
					@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
				)

				if($false)
				{
					$TT.DeclareTest("ZIP")
					[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
					$DiskManagement.Select_Disks($USBFilters)
					#write-host $DiskManagement.FilteredDisks[0]
					#write-host $DiskManagement.FilteredDisks.gettype()
					#pause
					$DiskManagement.getcount() | Should be 2
					#$DiskManagement.PrepDisks('NTFS')
					#$DiskManagement.ApplyZip("$($TT.Instance_SourceDir)\TestZip.zip")
				}

			}
			It "Applies Contents" {
				<#
				.SYNOPSIS

				#>

				if($false)
				{
					Disable_AutoMount
					$TT.DeclareTest("ZIP")
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
						"NewFileSystemLabel" = "Win_PE_Console"
					}
					# ==========================================================
					# DESCRIPTION:
					#	one item filters being applied with Select_Disks
					# ==========================================================
					$ZipSource = $Global:TestZip

					$USBFilters = @(
						@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
					)
					[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
					$DiskManagement.Select_Disks($USBFilters)
					$DiskManagement.getcount() | Should be 1

					#"$Dir\TestZip.zip"

					$Source_HashCode = "Fake HASH"
					#$Source_HashCode = ( Get-ChildItem "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759" -Recurse | Get-FileHash).Hash

					#$Source_HashCode = Get-FolderHash_1("$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759")

					#$Source_HashCode = Get-FolderHash "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759"
					write-host "$Global:TestZip"
					$TT.IsFile($ZipSource) | Should be $True

					#pause
					$DiskManagement.PrepDisks("NTFS")

					#$DiskManagement.CheckDiskSettings($DiskFormat) | Should be $True

					#$DiskManagement.ApplyZip($Global:TestZip)
					$DiskManagement.ApplyFolderContents($Global:TestDir)
					write-host $DiskManagement.GetDrivePaths()

					$DiskManagement.GetDrivePaths() | % {
						$SourceFiles   = $($((Get-ChildItem "$Global:TestDir" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count)
						$SourceFiles | should not be 0
						$MigratedFiles = $($((Get-ChildItem $_ -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
						write-host "$_ contains: $MigratedFiles, Expected: $SourceFiles"
						$MigratedFiles | Should be $SourceFiles
					}



					$CID            = 88888888
					$OrderNumber    = 12345678


					$DiskManagement.SaveLogs("C:\",$CID,$OrderNumber)
					Enable_AutoMount
					CheckForErrors -Message "Something Went wrong"
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
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
						"NewFileSystemLabel" = "Win_PE_Console"
					}
					# ==========================================================
					# DESCRIPTION:
					#	one item filters being applied with Select_Disks
					# ==========================================================
					$ZipSource = $Global:TestZip

					$USBFilters = @(
						@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
					)
					[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
					$DiskManagement.Select_Disks($USBFilters)
					$DiskManagement.getcount() | Should be 1

					#"$Dir\TestZip.zip"

					$Source_HashCode = "Fake HASH"
					#$Source_HashCode = ( Get-ChildItem "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759" -Recurse | Get-FileHash).Hash

					#$Source_HashCode = Get-FolderHash_1("$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759")

					#$Source_HashCode = Get-FolderHash "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759"
					write-host "$Global:TestZip"
					$TT.IsFile($ZipSource) | Should be $True

					#pause
					$DiskManagement.PrepDisks("MBR")
					$DiskManagement.CheckDisks()
					#$DiskManagement.CheckDiskSettings($DiskFormat) | Should be $True

					$DiskManagement.ApplyZip($Global:TestZip)
					#$DiskManagement.ApplyFolderContents($Global:TestDir)
					write-host $DiskManagement.GetDrivePaths()

					$DiskManagement.GetDrivePaths() | % {
						$SourceFiles   = $($((Get-ChildItem "$Global:TestDir" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count)
						$SourceFiles | should not be 0
						$MigratedFiles = $($((Get-ChildItem $_ -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
						write-host "$_ contains: $MigratedFiles, Expected: $SourceFiles"
						$MigratedFiles | Should be $SourceFiles
					}



					$CID            = 88888888
					$OrderNumber    = 12345678


					$DiskManagement.SaveLogs("C:\",$CID,$OrderNumber)
					Enable_AutoMount
					CheckForErrors -Message "Something Went wrong"
				}
			}
			It "Applies ZIP" {
				<#
				.SYNOPSIS

				#>

				if($True)
				{
					Disable_AutoMount
					$TT.DeclareTest("ZIP")
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
						"NewFileSystemLabel" = "Win_PE_Console"
					}
					# ==========================================================
					# DESCRIPTION:
					#	one item filters being applied with Select_Disks
					# ==========================================================
					$ZipSource = $Global:TestZip

					$USBFilters = @(
						@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
					)
					[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
					$DiskManagement.Select_Disks($USBFilters)
					$DiskManagement.getcount() | Should be 1

					#"$Dir\TestZip.zip"

					$Source_HashCode = "Fake HASH"
					#$Source_HashCode = ( Get-ChildItem "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759" -Recurse | Get-FileHash).Hash

					#$Source_HashCode = Get-FolderHash_1("$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759")

					#$Source_HashCode = Get-FolderHash "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759"
					write-host "$Global:TestZip"
					$TT.IsFile($ZipSource) | Should be $True

					#pause
					$DiskPartition = @{
						PartitionStyle     = "MBR";
						PartitionSize      = "ALL";
						FileSystem         = "NTFS";
						BlockSize          = 4096;
						Label              = "Win_PE_Console"
					}
					$DiskManagement.PrepDisks("MBR",$DiskPartition)

					$DiskManagement.CheckDisks($DiskPartition)
					#$DiskManagement.CheckDiskSettings($DiskFormat) | Should be $True

					$DiskManagement.ApplyZip($Global:TestZip)
					#$DiskManagement.ApplyFolderContents($Global:TestDir)
					write-host $DiskManagement.GetDrivePaths()

					$DiskManagement.GetDrivePaths() | % {
						$SourceFiles   = $($((Get-ChildItem "$Global:TestDir" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count)
						$SourceFiles | should not be 0
						$MigratedFiles = $($((Get-ChildItem $_ -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
						write-host "$_ contains: $MigratedFiles, Expected: $SourceFiles"
						$MigratedFiles | Should be $SourceFiles
					}



					$CID            = 88888888
					$OrderNumber    = 12345678


					$DiskManagement.SaveLogs("C:\",$CID,$OrderNumber)

					Enable_AutoMount
					CheckForErrors -Message "Something Went wrong"
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
					$DiskFormat = @{
						"PartitionStyle"     = "MBR";
						"FileSystem"         = "NTFS";
						"BlockSize" = 4096;
						"NewFileSystemLabel" = "Win_PE_Console"
					}
					# ==========================================================
					# DESCRIPTION:
					#	one item filters being applied with Select_Disks
					# ==========================================================
					$ZipSource = $Global:TestZip

					$USBFilters = @(
						@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";}
					)
					[DiskManagement]$DiskManagement = [DiskManagement]::new($DiskFormat)
					$DiskManagement.Select_Disks($USBFilters)
					$DiskManagement.getcount() | Should be 1

					#"$Dir\TestZip.zip"

					$Source_HashCode = "Fake HASH"
					#$Source_HashCode = ( Get-ChildItem "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759" -Recurse | Get-FileHash).Hash

					#$Source_HashCode = Get-FolderHash_1("$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759")

					#$Source_HashCode = Get-FolderHash "$($TT.Instance_SourceDir)\I-20233-3759\I-20233-3759"
					write-host "$Global:TestZip"
					$TT.IsFile($ZipSource) | Should be $True

					#pause
					$DiskPartitions = @(
							@{
								PartitionStyle     = "MBR";
								PartitionSize      = 100MB;
								FileSystem         = "NTFS";
								BlockSize          = 4096;
								Label              = "Win_PE_Console_0";
								ApplyZIP           = $Global:TestZip;
						},
							@{
								PartitionStyle     = "MBR";
								PartitionSize      = 100MB;
								FileSystem         = "NTFS";
								BlockSize          = 4096;
								Label              = "Win_PE_Console_1";
								ApplyZIP           = $NULL;
						}
					)
					$DiskManagement.AddPartitions($DiskPartitions)

					$DiskManagement.CheckDisks($DiskPartitions)
					#$DiskManagement.CheckDiskSettings($DiskFormat) | Should be $True

					$DiskManagement.ApplyZip($Global:TestZip)
					#$DiskManagement.ApplyFolderContents($Global:TestDir)
					write-host $DiskManagement.GetDrivePaths()

					$DiskManagement.GetDrivePaths() | % {
						$SourceFiles   = $($((Get-ChildItem "$Global:TestDir" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count)
						$SourceFiles | should not be 0
						$MigratedFiles = $($((Get-ChildItem $_ -Recurse) | where {$_ -is [System.IO.FileInfo]}).Count)
						write-host "$_ contains: $MigratedFiles, Expected: $SourceFiles"
						$MigratedFiles | Should be $SourceFiles
					}



					$CID            = 88888888
					$OrderNumber    = 12345678


					$DiskManagement.SaveLogs("C:\",$CID,$OrderNumber)

					Enable_AutoMount
					CheckForErrors -Message "Something Went wrong"
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

}
